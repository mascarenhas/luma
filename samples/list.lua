
x = L[[i for i = 1,5]]

y = L[[L[=[j for j=1,3]=] for i=1,3]]

print(unpack(x))

for _, v in ipairs(y) do print(unpack(v)) end


