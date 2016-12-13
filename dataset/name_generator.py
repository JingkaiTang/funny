#!/usr/bin/env python
import json
from random import choice

if __name__ == '__main__':
    data = json.load(open('names.json'))
    last_name = lambda: choice(data['lname'])
    first_name = lambda: ''.\
                 join([choice(data['fname']) for i in range(choice([1, 2, 2]))])
    names = [last_name() + first_name() for i in range(10)]
    print('\n'.join(names))

