#!/usr/bin/env python
import json
import random

if __name__ == '__main__':
    data = json.load(open('names.json'))
    ng = lambda: random.choice(data['lname']) + random.choice(data['fname']) + (random.choice(data['fname']) if random.choice([True, False]) else '')
    print('\n'.join([ng() for i in range(10)]))

