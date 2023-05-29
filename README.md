# Минимизация сложности в смарт контрактах для выплат дивидендов

Инвесторы приобретают ценные бумаги, что дает им право получать часть прибыли от активов (дивиденды). Выплаты дивидендов могут быть реализованы в децентрализованных сетях посредством исполнения смарт контрактов. Данная работа нацелена на разработку алгоритмов эффективной выплаты дивидендов, минимизирующих количество потребляемого газа для различных автоматизированных сценариев. Реализация алгоритмов ведется на языке программирования смарт контрактов Solidity. В данной работе предложено несколько алгоритмов, а также показано преимущество каждого из них для различных сценариев.


## Постановка задачи


Целью работы является разработка и реализация алгоритмов, которые позволяли бы решать задачу выплаты дивидендов эффективно. Заранее известна матрица выплат, столбцы которой отвечают за ценные бумаги, строки за финансовые активы, а значения соответствующих ячеек за количество актива в ценной бумаге. После произвольной обработки заданной матрицы выплат, а также ее загружения в смарт контракт, необходимо уметь, принимая на вход массив стоимостей соответствующих активов, вычислять количество денег, которое положено каждому инвестору в соответствии с заранее известной матрицей выплат. 

Говоря более формальным языком, постановку задачи выплат дивидендов можно описать следующим образом:

* Есть матрица $A \in \mathbb{R}^{m \times n}$, где $m$ – количество различных финансовых активов, а $n$ – число ценных бумаг. Значение ячейки $A_{i, j}$ содержит в себе количество $i$-го актива в $j$-ой ценной бумаге.
    
* Имеется вектор-столбец $C \in \mathbb{R}^{m}$ стоимостей финансовых активов $C = (C_1, \ldots, C_m)^T$, где $C_{i}$ – стоимость $i$-го актива.
    
* Есть вектор $I \in \mathbb{R}^{n}$ соответствий ценных бумаг и инвесторов, т.е. $I_{i}$ – номер инвестора, вложившийся $i$-ую в ценную бумагу.

Требуется произвести выплату дивидендов. А именно, инвестор с номером $i$ должен получить на свой счет сумму денег, соответствующую всем ценным бумагам, которые он приобрел. Если обозначить через $\text{cost}[s]$ – "прибыль" $s$-ой ценной бумаги, а через $\text{balances}[i]$ – прибыль $i$-го инвестора, то:

$$
\text{balances}[i] = \sum \limits_{s = 1}^{n} \text{cost}[s] \cdot [i = I_s]
\text{, где }
[a = b] =
\begin{cases}
   1 &\text{если $a = b$}\\
   0 &\text{если $a \neq b$}
 \end{cases}
$$

$$
\text{cost}[s] = \sum \limits_{i = 1}^{m} C_{i} A_{i, s} \Longleftrightarrow{} \text{cost} = C^T A = (A^T C)^T
$$

Целью является вычисления массива $\text{balances}[i]$ алгоритмически по входным данным $A, C, I$ таким образом, чтобы количество потребляемого газа в смарт контракте было минимально возможным. 


## Тестируем реализации

На данный момент мною реализовано 4 алгоритма для payout-функции:

1. Наивная реализация: `payoutNaive`. Хранит матрицу в несжатом виде, алгоритм выплаты – наивный
2. Алгоритм для разреженной матрицы: `payoutSparse`. Хранит матрицу в сжатом виде (формат *COO*)
3. Алгоритм для дублирующихся столбцов: `payoutRepeatedColumns`. Хранит матрицу в сжатом виде
4. Алгоритм для малоранговой матрицы: `payoutLowRank`. Случай повторяющихся столбцов *(3)* является частным случаем малоранговой матрицы, но при этом в нем можно сделать более эффективную оптимизацию количества газа.

С тем, как работают соответствующие алгоритмы, как происходит процесс тестирования и генерация тестов можно ознакомиться более подробно в документе [paper.pdf](source_files/paper.pdf).

Посмотрим, какие преимущества дает каждый из алгоритмов. Для этого протестируем эти алгоритмы для различных наборах входных данных:
* Плотные матрицы
* Разреженные матрицы (степень разреженности задается параметров `capacity`)
* Матрицы с повторяющимися столбцами
* Малоранговые матрицы
* Квадратные матрицы
* Прямоугольные высокие матрицы и прямоугольные широкие матрицы


```python
import numpy as np
import numpy.linalg as la
import matplotlib.pyplot as plt
import scipy.sparse as sp
import scipy.linalg
import scipy.sparse.linalg as spla
import time
%matplotlib inline
```


```python
import importlib.util
import checker
import test.test_generator as generator

# importlib.reload(checker)
# importlib.reload(generator)
```

### Плотные матрицы

**Плотная матрица** – это матрица, в которой мало нулевых элементов. Не будем предполагать, что у этой матрицы есть какая-то особенная структура (малый ранг, повторяющиемся столбцы/элементы и т.д.)

Посмотрим, сколько газа потребляет каждый из алгоритмов в данном случае:


```python
def get_gas_info_dense(X):
    naive = []
    sparse = []
    repeated_cols = []
    low_rank = []
    for x in X:
        matrix = generator.generate_random(x, x)
        assets_cost = [i for i in range(x)]
        j = checker.get_timings(matrix, assets_cost)
        naive.append(j.get('payoutNaive'))
        sparse.append(j.get('payoutSparse'))
        repeated_cols.append(j.get('payoutRepeatedColumns'))
        low_rank.append(j.get('payoutLowRank'))
    return naive, sparse, repeated_cols, low_rank
```


```python
X_dense = [10 * i for i in range(1, 11)]
naive, sparse, repeated_cols, low_rank = get_gas_info_dense(X_dense)
```


```python
plt.plot(X_dense, np.c_[naive, sparse, repeated_cols, low_rank])
plt.legend(["naive", "sparse", "repeat", "low-rank"])
plt.xlabel("n")
plt.ylabel("gas")
plt.title("Dense matrix")
plt.grid(True)
plt.show()
```


    
![jpg](static_files/dense_matrix.jpg)
    


**Вывод:**

Видно, что с плотными матрицами быстрее работает алгоритм `payoutNaive`, который рассчитывает размер диведендов и хранит матрицу в явном виде без каких-либо оптимизаций.

При этом, как можно видеть, алгоритм `payoutSparse`, предназначенных для разреженных матриц, работает заметно хуже других алгоритмов. Это можно легко объясняется следующим фактом: для разреженной матрицы с $k$ элементами требуется хранить 3 массива размера $k$, что в случае плотных занимает в $3$ раза больше пямяти, чем наивный подход.

### Разреженные матрицы

**Разреженная матрица** – это матрица, в которой много нулей (обычно больше, чем ненулевых элементов). Не будем предполагать в этом пункте, что у матрицы есть какая-либо дополнительная структура, кроме разреженности.

Посмотрим, каким образом будет вести себя количество потребляемого газа в зависимости от используемого алгоритма и степени разреженности матрицы (`capacity`):


```python
def get_gas_info_sparse(X, capacity = 20):
    naive = []
    sparse = []
    repeated_cols = []
    low_rank = []
    for x in X:
        matrix = generator.generate_sparse(x, x)
        assets_cost = [i for i in range(x)]
        j = checker.get_timings(matrix, assets_cost)
        naive.append(j['payoutNaive'])
        sparse.append(j['payoutSparse'])
        repeated_cols.append(j['payoutRepeatedColumns'])
        low_rank.append(j.get('payoutLowRank'))
    return naive, sparse, repeated_cols, low_rank
```


```python
X_sparse = [10 * i for i in range(1, 11)]
naive, sparse, repeated_cols, low_rank = get_gas_info_sparse(X_sparse, 20)
```


```python
plt.plot(X_sparse, np.c_[naive, sparse, repeated_cols, low_rank])
plt.legend(["naive", "sparse", "repeat", "low-rank"])
plt.xlabel("n")
plt.ylabel("gas")
plt.title("Sparse matrix with capacity = 20%")
plt.grid(True)
plt.show()
```


    
![jpg](static_files/sparse_20.jpg)
    


**Вывод:**

Видно, что алгоритм для разреженных матриц заметно выигрывает (разница более чем в два раза).

При этом, что интересно подметить, алгоритм `payoutRepeatedColumns` для матриц с одинаковыми столбцами несколько медленне, чем наивный `payoutNaive`. Объяснить этом можно тем, что из-за особенности хранения данных в `payoutRepeatedColumns`, на матрицах без нужной структуры есть небольшой оверхед, по сравнению с `payoutNaive`

### Повторяющиеся столбцы

Под матрицей с повторяющимися столбцами будем подразумевать следующее:

* Пусть есть некоторый набор столбцов $A_1, \ldots, A_k$, где $k << n$
* Тогда искомая матрица $A \in \mathbb{R}^{n \times n}$ имеет вид:
$$
A = \left( A_{i_1} | A_{i_2} | \ldots | A_{i_n} \right) \text{, где } i_j = 1 \ldots k
$$


```python
def get_gas_info_repeated(X, capacity = 20):
    naive = []
    sparse = []
    repeated_cols = []
    low_rank = []
    for x in X:
        r = (capacity * x) // 100
        matrix = generator.generate_repeated_columns(x, x, r)
        assets_cost = [i for i in range(x)]
        j = checker.get_timings(matrix, assets_cost)
        naive.append(j.get('payoutNaive'))
        sparse.append(j.get('payoutSparse'))
        repeated_cols.append(j.get('payoutRepeatedColumns'))
        low_rank.append(j.get('payoutLowRank'))
    return naive, sparse, repeated_cols, low_rank
```


```python
X_repeated = [10 * i for i in range(1, 11)]
naive_rep, sparse_rep, repeated_cols_rep, low_rank_rep = get_gas_info_repeated(X_repeated, 20)
```


```python
plt.plot(X_repeated, np.c_[naive_rep, sparse_rep, repeated_cols_rep, low_rank_rep])
plt.legend(["naive", "sparse", "repeat", "low_rank"])
plt.xlabel("n")
plt.ylabel("gas")
plt.title("Repeated columns with coef = 20%")
plt.grid(True)
plt.show()
```


    
![jpg](static_files/repeated_20.jpg)
    



```python
n = 100
m = 50
k = 4
L = np.random.randint(0, 100, (n, k))
R = np.random.randint(0, 100, (k, m))
A = L @ R

U, S, VT = np.linalg.svd(A, full_matrices=False)
A2 = (U[:, :k] * S[:k]) @ VT[:k, :]
```

### Матрицы малого ранга

В данном разделе будем предполагать, что исходная матрица $A \in \mathbb{R}^{n \times n}$ имеет ранг, заметно меньший, чем $n$, т.е. $rank{A} \ll n$. Например, $k \approx \frac{1}{5}n$. 

Параметр ``capacity`` задает отношение $\frac{rank A}{n}$. Положим в данной секции, что ``capacity = 20%``


```python
def get_gas_info_low_rank(X, capacity = 20):
    naive = []
    sparse = []
    repeated_cols = []
    low_rank = []
    for x in X:
        r = (capacity * x) // 100
        matrix = generator.generate_low_rank(x, x, r)
        assert np.array(matrix).shape == (x, x)
        assets_cost = [i for i in range(x)]
        j = checker.get_timings(matrix, assets_cost)
        naive.append(j.get('payoutNaive'))
        sparse.append(j.get('payoutSparse'))
        repeated_cols.append(j.get('payoutRepeatedColumns'))
        low_rank.append(j.get('payoutLowRank'))
    return naive, sparse, repeated_cols, low_rank
```


```python
X_repeated = [10 * i for i in range(1, 11)]
naive_lr, sparse_lr, repeated_cols_lr, low_rank_lr = get_gas_info_low_rank(X_repeated, 20)
```


```python
plt.plot(X_repeated, np.c_[naive_lr, sparse_lr, repeated_cols_lr, low_rank_lr])
plt.legend(["naive", "sparse", "repeat", "low_rank"])
plt.xlabel("n")
plt.ylabel("gas")
plt.title("Low rank matrix with r = 20% n")
plt.grid(True)
plt.show()
```


    
![jpg](static_files/sparse_20.jpg)
    

