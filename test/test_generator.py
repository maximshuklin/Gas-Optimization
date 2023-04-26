import numpy as np
import random

def generate_random(n, m, max_value = 100):
	"""
	Parameters:
		n, m - shape of array
		max_value - maximal allowed value for array (0...max_value)
	Returns:
		Matrix A size of n x m and 0 <= A[i][j] <= max_value
	"""
	arr = [[random.randint(0, max_value) for col in range(m)] for row in range(n)]
	return arr

def generate_sparse(n, m, cap = 20, max_value = 100):
	"""
	Parameters:
		n, m - shape of array
		cap  - fullness of sparse matrix
	Returns:
		Sparse matrix size of n x m with cap percent of filled elements
	"""

	arr = [[0 for col in range(m)] for row in range(n)]
	for it in range(n * m * cap // 100):
		i = random.randint(0, n - 1)
		j = random.randint(0, m - 1)
		while arr[i][j] != 0:
			i = random.randint(0, n - 1)
			j = random.randint(0, m - 1)

		arr[i][j] = random.randint(0, max_value)

	return arr


def generate_low_rank(n, m, r, max_value = 100):
	"""
	Parameters:
		n, m - shape of array
		r - desired rank of matrix
	Returns:
		Triple (A, U, V) such as A = UV, where
		A - n x m matrix rank of r
		U - n x r matrix, V - r x m matrix
	"""

	U = generate_random(n, r, max_value)
	V = generate_random(r, m, max_value)
	A = np.array(U) @ np.array(V)
	return (A.tolist(), U, V)

def display_matrix(A):
	n = len(A)
	m = len(A[0])
	for i in range(n):
		for j in range(m):
			print(A[i][j], end = ' ')
		print()


def debug_test_prints():
	print("Random matrix 3 x 5")
	display_matrix(generate_random(3, 5))

	print("Random matrix 5 x 6 with 20 percent capacity")
	display_matrix(generate_sparse(5, 6))

	print("Random matrix 5 x 5 with rank 2")
	A, U, V = generate_low_rank(5, 5, 2, 5)
	print("A:")
	display_matrix(A)
	print("U:")
	display_matrix(U)
	print("V:")
	display_matrix(V)


def make_test_random(n = 10, m = 10, max_value = 10):
	with open("test_random_matrix.txt", "w") as f:
		print(generate_random(n, m, max_value), file=f)

def make_test_sparse(n = 10, m = 10, cap = 20, max_value = 10):
	with open("test_sparse_matrix.txt", "w") as f:
		print(generate_sparse(n, m, cap, max_value), file=f)

def make_test_low_rank(n = 10, m = 10, r = 5, max_value = 10):
	with open("test_low_rank_matrix.txt", "w") as f:
		print(generate_low_rank(n, m, r, max_value), file=f)

make_test_random()
make_test_sparse()
make_test_low_rank()