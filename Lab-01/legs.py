import pandas as pd

def legs_sample():
  df = pd.DataFrame({'num_legs': [2, 4, 8, 0, 0], 'num_wings': [2, 0, 0, 0, 0], 'num_specimen_seen': [10, 2, 1, 8, 0]}, index=['falcon', 'dog', 'spider', 'fish', 'python'])
  return df['num_legs'].sample(n=3)
