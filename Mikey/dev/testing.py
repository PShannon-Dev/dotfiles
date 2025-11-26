#!/usr/bin/env python3

iterate = ["paint", "print", "Paul"]
i = 0
flag = False

while not flag:
    if iterate[i] == "Paul":
        print(i)
        flag = True
    i += 1

for word in iterate:
    print(word)

print("Completed")
