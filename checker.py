import json
import os
import numpy as np

prefix = "./test/data"
default_naive = f"{prefix}/naive.json"
default_sparse = f"{prefix}/sparse.json"
default_low_rank = f"{prefix}/low_rank.json"
default_repeated_columns = f"{prefix}/repeated_columns.json"
default_output = f"{prefix}/output.json"


def naive_transform(matrix, assets_cost, path=default_naive):
    n_assets = len(matrix)
    n_securities = len(matrix[0])
    correct_answer = []
    conf = {
        "n_assets": n_assets,
        "n_securities": n_securities,
        "assets_cost": assets_cost,
        "matrix": matrix,
        "correct_answer": correct_answer
    }

    with open(path, "w") as fout:
        print(json.dumps(conf), file=fout)


def sparse_transform(matrix, assets_cost, path=default_sparse):
    n_assets = len(matrix)
    n_securities = len(matrix[0])
    correct_answer = []
    payout_triples = []
    for i in range(n_assets):
        for j in range(n_securities):
            if matrix[i][j] != 0:
                payout_triples.append([i, j, matrix[i][j]])
    conf = {
        "n_assets": n_assets,
        "n_securities": n_securities,
        "assets_cost": assets_cost,
        "matrix": matrix,
        "payout_triples": payout_triples,
        "correct_answer": correct_answer
    }

    with open(path, "w") as fout:
        print(json.dumps(conf), file=fout)


def low_rank_transform(matrix, assets_cost, path=default_low_rank):
    """
            TODO!
    """
    eps_machine = 1e-9
    n_assets = len(matrix)
    n_securities = len(matrix[0])

    A = np.array(matrix)

    U, S, VT = np.linalg.svd(A, full_matrices=False)
    k = 0
    while k < len(S) and S[k] > eps_machine:
        k += 1
    L = (U[:, :k] * S[:k]).astype(int).tolist()
    R = VT[:k, :].astype(int).tolist()


    correct_answer = []
    conf = {
        "n_assets": n_assets,
        "n_securities": n_securities,
        "assets_cost": assets_cost,
        "matrix": matrix,
        "L": L,
        "R": R,
        "correct_answer": correct_answer
    }

    print(f"A is {A.shape}, k = {k}")

    with open(path, "w") as fout:
        print(json.dumps(conf), file=fout)


def repeated_columns_transform(
        matrix,
        assets_cost,
        path=default_repeated_columns):
    """
    Output:
            uint[] memory column_id, uint[][] memory columns, uint[] memory _assetsCost
            column_id = [1 2 3 2 3 1]
            columns = [
                    [column_1],
                    [column_2],
                    ...,
                    [column_k]
            ]
    """
    n_assets = len(matrix)
    n_securities = len(matrix[0])
    correct_answer = []
    column_id = []
    columns = []

    n_cols = 0

    for j in range(n_securities):
        same = -1
        for prev in range(j):
            is_equal = True
            for i in range(n_assets):
                if matrix[i][prev] != matrix[i][j]:
                    is_equal = False
                    break
            if is_equal:
                same = prev
                break
        if same == -1:
            n_cols += 1
            column_id.append(n_cols)
            columns.append([matrix[i][j] for i in range(n_assets)])
        else:
            column_id.append(column_id[same])

    conf = {
        "n_assets": n_assets,
        "n_securities": n_securities,
        "assets_cost": assets_cost,
        "matrix": matrix,
        "column_id": column_id,
        "columns": columns,
        "correct_answer": correct_answer
    }

    with open(path, "w") as fout:
        print(json.dumps(conf), file=fout)


def get_timings(matrix, assets_cost):
    naive_transform(matrix, assets_cost)
    sparse_transform(matrix, assets_cost)
    low_rank_transform(matrix, assets_cost)
    repeated_columns_transform(matrix, assets_cost)

    # os.system(f"npx hardhat compile >/dev/null 2>&1")
    os.system(f"npx hardhat test > {default_output} 2>/dev/null ")

    function_names = [
        "payoutNaive",
        "payoutSparse",
        "payoutRepeatedColumns",
        "payoutLowRank"
    ]

    gas = dict()

    with open(default_output, "r") as fin:
        for line in fin:
            if line.find("PayoutContract") != -1:
                gas_amounjt = 0
                for s in line.split(" "):
                    if s.isdigit() == True:
                        gas_amount = int(s)
                        break

                for funcname in function_names:
                    if line.find(funcname) != -1:
                        gas[funcname] = gas_amount

    return gas

gas = get_timings([
    [1, 2],
    [2, 3],
    [3, 4]
    ], [1, 1, 10])

print(gas)
