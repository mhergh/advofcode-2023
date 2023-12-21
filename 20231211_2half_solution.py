import copy
import os
import sys
import re

# <filename> == sys.argv[1]

# SUB
UNINITIALISED = '.'
position_galaxy = [] # galaxy position list in form fo tuples: (i, j) == (row, column)
dist_galaxy = {} # min. dist. between 2 galaxies: ((i1, j1), (i2, j2)) -> dist
idx_empty_row = [] # list of empty row indexes aka '.'
idx_empty_column = [] # list of empty column indexes aka '.'
idx_nonempty_column = set() # set of non-empty column indexes aka '.'
sum_comb2_galaxies = 0
factor = 999999 # if they are 1000000, the multiplicator is 1000000 - 1 = 999999, because 1 of the items already considered in the standard abs(delta_row) + abs(delta_col)

def dichotomic_search(vector, t):
    ''' seaches within the vector what is the index such that: vector[index] <= t < vector[index + 1] (if index + 1 is still a valid index)
        - returns index, vector[index]
        - assumes vector:
            - is non-empty
            - is sorted ascending
            - contains no duplicated values
    '''
    if t < vector[0]:
        return -1, None 
    b = len(vector) - 1
    if vector[b] <= t:
        return b, vector[b]
    a = 0
    while b - a >= 2:
        n = int((a + b)/2)
        cmp_val = vector[n]
        if cmp_val == t:
            return n, cmp_val
        if cmp_val < t:
            a = n
        else:
            b = n
    return a, vector[a]

def get_min_dist_between_galaxies(g1, g2, factor):
    '''g1, g2 are galaxies provided as tuples: (i1, j1), (i2, j2) in format: (row, col)
        - factor is new to 11_2, equated with factor == 1 for 11_1
    '''
    d_min = abs(g1[0] - g2[0]) + abs(g1[1] - g2[1]) # without the gaps (aka empty lines, cols)
    d_min += (abs(dichotomic_search(idx_empty_row, g1[0])[0] - dichotomic_search(idx_empty_row, g2[0])[0]) * factor)         # number of empty rows between g1 and g2; only the first returned value of the function is relevant
    d_min += (abs(dichotomic_search(idx_empty_column, g1[1])[0] - dichotomic_search(idx_empty_column, g2[1])[0]) * factor)  # number of empty cols between g1 and g2; only the first returned value of the function is relevant
    global dist_galaxy
    dist_galaxy[(g1, g2)] = d_min
    return d_min

def get_total_min_dist_comb2_galaxies(p_g, factor):
    sum = 0
    for idx_g1 in range(0, len(p_g) - 1):
        for idx_g2 in range(idx_g1 + 1, len(position_galaxy)):
            sum += get_min_dist_between_galaxies(p_g[idx_g1], p_g[idx_g2], factor)
    return sum

# MAIN
if __name__ == '__main__':
    print(f'file name: <{sys.argv[1]}>')
    nr_cols = 0
    nr_rows = 0
    line_pattern = ''
    empty_line_pattern = ''
    [y, x] = [0, 0] # coordinates: x - horiz. (left -> right) from 0 .. max, y vertical from 0 .. max (top -> bottom); [0, 0] == upper left
    idx_row = 0
    with open(sys.argv[1], 'r') as file:
        for line in file:
            line = line.strip()
            # assuming that lines are either with galaxies or without galaxies; however, all valid (same length and no other chars besides '.' and '#')
            if not nr_cols:
                nr_cols = len(line)
                empty_line_pattern = '^[.]{' + str(nr_cols) + '}$'
            match = re.match(empty_line_pattern, line)
            if match: # no galaxies on this line
                idx_empty_row.append(idx_row)
            else: # there are galaxies on this line
                for idx_col, char in enumerate(line):
                    if char == '#': # galaxy found
                        idx_nonempty_column.add(idx_col)
                        position_galaxy.append((idx_row, idx_col))
            idx_row += 1
    
    # 1. fill list of indexes without galaxies
    idx_empty_column = sorted([idx for idx in range(nr_cols) if idx not in idx_nonempty_column])

    # 2. get the sum of min. dist.  across all galaxy pairs
    sum_comb2_galaxies = get_total_min_dist_comb2_galaxies(position_galaxy, factor)
    print(f'number of located galaxies: <{len(position_galaxy)}>; total of min distances: <{sum_comb2_galaxies}>')
    print(f'END')
    