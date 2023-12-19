import copy
import os
import sys
import re

# <filename> == sys.argv[1]

# SUB
map = []
max_x = -1
max_y = -1
S = [-1, -1] # start position
upper_length = 40000 # prevent infinite loop; a length >= with this woould indicate a bug
map2 = [] # contains the map filled with only the cicle and 'O' for outside and 'I' for inside
map2_nr_I = 0 # nr. of internal points
UNINITIALISED = '.'
COLOR_RESET = '\033[m'

def initMap2():
    '''initializes map2 based on map
    '''
    global map2
    map2 = [[UNINITIALISED for _ in range(len(map[0]))] for _ in range(len(map))]

def setCharAtPositionMap2(p, c):
    global map2
    map2[p[0]][p[1]] = c

def invert_state(state):
    ''' 'O' == <outside>; 'I' == <inside> (related to the cycle)
    '''
    match state:
        case 'O':
            return 'I'
        case 'I':
            return 'O'
        case _:
            return None

def get_horizontal_token_at_pos(p):
    ''' acts on map2; assumes any row in map2 is made solely out of VALID tokens
        however, the real scope of this function is to gather the border-tokens
        p[y, x]
        - returns the horizontal token and the position of token's last character
            - valid tokens are: {UNITIALISED, 'LJ' == '┗┛', 'F7' == '┏┓', 'L7' == '┗┓', 'FJ' == '┏┛', '|', <whatever-else-char>}
            - if no token can be identified (for instance after end of row), returns None
            - return sample: ['L7', [7, 5]]
    '''
    if p[0] >= len(map2) or p[1] >= len(map2[0]): # p out of range for map2
        return [None, None]
    if map2[p[0]][p[1]] not in ['L', 'F']: # 1 char token
        return [map2[p[0]][p[1]], p]
    else: # multichar token
        p_last = copy.deepcopy(p)
        p_last[1] += 1
        while(map2[p_last[0]][p_last[1]] in ['-']):
            p_last[1] += 1
        return map2[p[0]][p[1]] + map2[p_last[0]][p_last[1]], p_last

def set_states_on_row(idx_row):
    ''' acts on map2
        - parses horizontally the map2 row given by the index and for the UNINITIALISED fields sets accordingly the state to <outside> or <inside>
    '''
    global map2_nr_I
    state = 'O'
    idx_column = 0
    p = [idx_row, idx_column]
    while(1):
        (token, p) = get_horizontal_token_at_pos(p)
        if token:
            match token:
                case '.':
                    map2[p[0]][p[1]] = state
                    if state == 'I':
                        map2_nr_I += 1
                case 'L7' | 'FJ' | '|':
                    state = invert_state(state)
            p[1] += 1
        else:
            break

def set_states_on_map2():
    for i in range(len(map2)):
        set_states_on_row(i)

def getUTF8Char(c):
    match c:
        case 'F':
            return chr(0x250F) # HEAVY DOWN AND RIGHT
        case 'J':
            return chr(0x251B) # HEAVY UP AND LEFT
        case 'L':
            return chr(0x2517) # HEAVY UP AND RIGHT
        case '7':
            return chr(0x2513) # HEAVY DOWN AND LEFT
        case '|':
            return chr(0x2503) # HEAVY VERTICAL
        case '-':
            return chr(0x2501) # HEAVY HORIZONTAL
        case _:
            return c

def showRAWMap2():
    for row in map2:
        print(''.join(row))

def get_color_code(char):
    match char:
        case 'O':
            return '\033[32m' # green
        case 'I':
            return '\033[31m' # red
        case _:
            return '' # default

def showMap2():
    map3 = copy.deepcopy(map2)
    for i in range(len(map2)):
        for j in range(len(map2[0])):
            map3[i][j] = getUTF8Char(map2[i][j])
    for i in range(len(map2)):
        for j in range(len(map2[0])):
            char = map3[i][j]
            print(get_color_code(char) + char + COLOR_RESET, end='')
        print()


def getNextPosition(p, action, p_prev):
    '''p = [y, x]; returns the next position if <action> will be applied; p_prev is the previous position
        - | is a vertical pipe connecting north and south.
        - is a horizontal pipe connecting east and west.
        - L is a 90-degree bend connecting north and east.
        - J is a 90-degree bend connecting north and west.
        - 7 is a 90-degree bend connecting south and west.
        - F is a 90-degree bend connecting south and east.
        - . is ground; there is no pipe in this tile.
        - S is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.
    '''
    p_next = copy.deepcopy(p)
    match action:
        case '|': # N <-> S
            if p[1] != p_prev[1]:
                return None # x not same; bug
            if p[0] > p_prev[0]:
                p_next[0] += 1
            else:
                p_next[0] -= 1
        case '-': # E <-> W
            if p[0] != p_prev[0]:
                return None # y not same; bug
            if p[1] > p_prev[1]:
                p_next[1] += 1
            else:
                p_next[1] -= 1
        case 'L': # N <-> E
            if p[1] < p_prev[1] and p[0] == p_prev[0]:
                p_next[0] -= 1 # E -> N
            elif p[0] > p_prev[0] and p[1] == p_prev[1]:
                p_next[1] += 1 # N -> E
            else:
                return None
        case 'J': # N <-> W
            if p[1] > p_prev[1] and p[0] == p_prev[0]:
                p_next[0] -= 1 # W -> N
            elif p[0] > p_prev[0] and p[1] == p_prev[1]:
                p_next[1] -= 1 # N -> W
            else:
                return None
        case '7': # S <-> W
            if p[1] > p_prev[1] and p[0] == p_prev[0]:
                p_next[0] += 1 # W -> S
            elif p[0] < p_prev[0] and p[1] == p_prev[1]:
                p_next[1] -= 1 # S -> W
            else:
                return None
        case 'F': # E <-> S
            if p[1] < p_prev[1]:
                p_next[0] += 1 # E -> S
            elif p[0] < p_prev[0]:
                p_next[1] += 1 # S -> E
            else:
                return None
        case _:
            return None
    if x > max_x or y > max_y:
        print('next outside boundaries; not possible to follow here')
        return None
    return p_next

def getCharAtPosition(position):
    '''acts on the global map[]
        - position == [y, x]
    '''
    if not position or position[0] < 0 or position[1] < 0:
        return None
    return map[position[0]][position[1]]

def getPrevPosAndActionOfStart(Start):
    ''' Start is just a clobber of one of accepted actions; I have to identify it based on adjacent pipes
        - however, I will assume that S is not on the border (is theoretically connectable in all 4 directions: N, S, E, W)
        - nb_<N, S , E, W> neighbor in the respective direction
        - as per spec. there is exactly 1 pair connectable in the neighborhood

        returns:
        - [[previous position], action]
    '''
    [pos_nb_N, pos_nb_S, pos_nb_E, pos_nb_W] = [copy.deepcopy(Start), copy.deepcopy(Start), copy.deepcopy(Start), copy.deepcopy(Start)]
    pos_nb_N[0] -= 1
    pos_nb_S[0] += 1
    pos_nb_W[1] -= 1
    pos_nb_E[1] += 1
    [nb_N, nb_S, nb_W, nb_E] = [getCharAtPosition(position) for position in [pos_nb_N, pos_nb_S, pos_nb_W, pos_nb_E]]
    if nb_N in ['7', 'F', '|'] and nb_S in ['J', 'L', '|']:
        return pos_nb_S, '|'
    elif nb_N in ['7', 'F', '|'] and nb_E in ['J', '7', '-']:
        return pos_nb_E, 'L'
    elif nb_N in ['7', 'F', '|'] and nb_W in ['L', 'F', '-']:
        return pos_nb_W, 'J'
    elif nb_S in ['J', 'L', '|'] and nb_E in ['J', '7', '-']:
        return pos_nb_E, 'F'
    elif nb_S in ['J', 'L', '|'] and nb_W in ['L', 'F', '-']:
        return pos_nb_W, '7'
    elif nb_E in ['J', '7', '-'] and nb_W in ['L', 'F', '-']:
        return pos_nb_W, '-'

def parseCycle():
    ''' parses the cycle and:
        - copies in the map2 the correspoding cycle path; the S will be set to the real action
        returns the cyle length
    '''
    p = copy.deepcopy(S) # current position; initialised to Start
    prev_p = None # previous position
    length = 0 # cycle length
    [prev_p, action] = getPrevPosAndActionOfStart(S)
    while 1:
        setCharAtPositionMap2(p, action)
        p_next = getNextPosition(p, action, prev_p)
        prev_p = p
        p = p_next
        action = getCharAtPosition(p)
        length += 1
        if action in ['S']:
            return length
        elif length > upper_length:
            print(f'length over <{upper_length}>; return None')
            return None

# MAIN
if __name__ == '__main__':
    print(f'file name: <{sys.argv[1]}>')
    line_length = 0
    nr_steps = 0
    pattern = ''
    [y, x] = [0, 0] # coordinates: x - horiz. (left -> right) from 0 .. max, y vertical from 0 .. max (top -> bottom); [0, 0] == upper left
    idx_line = 0
    with open(sys.argv[1], 'r') as file:
        for line in file:
            line = line.strip()
            if not line_length:
                line_length = len(line)
                pattern = r'[-|LJ7F.S]{' + str(line_length) + '}$'
            if re.match(pattern, line):
                char_list = list(line)
                map.append(char_list)
                if S[0] == -1: # S not yet detected
                    match = re.search(r'S', line)
                    if match:
                        S = [idx_line, match.start()]
                        print(f'S located: [y, x] == <{S}>')
                idx_line += 1
            elif re.match(r'^\s*$', line):
                pass
            else:
                # Print the line if it doesn't contain an image URL
                print(f'unrecognized line provided: <{line}>')
    max_y = idx_line - 1
    max_x = line_length -1
    upper_length = (max_x + 1) * (max_y + 1)
    initMap2()
    nr_steps = int(parseCycle() / 2)
    print(f'number of steps max distance from S: <{nr_steps}>')
    set_states_on_map2()
    #showRAWMap2()
    showMap2()
    print(f'nr. of Internal points: <{map2_nr_I}>')
    print(f'END')
    