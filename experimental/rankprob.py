# # # # # # # # # # #
# Rank functions Daniel Ford, Tanja Gernhard 2006
# Functions:
# rankprob(t,u)     - returns the probability distribution
#                     of the rank of vertex "u" in tree "t"
# expectedrank(t,u) - returns the expected rank
#                     of vertex "u" and the variance
# compare(t,u,v)    - returns the probability that "u"
#                     is below "v" in tree "t"
import random

# # # # # #
# How we store the trees: The interior vertices of a tree with n leaves are
# labeled by 1...n-1
# Example input tree for all the algorithms below: The tree "t" below has
# n=9 leaves and the inner nodes have label 1...8

t1 = (((), (), {'leaves_below': 2, 'label': 4}), (),
	{'leaves_below': 3, 'label': 3})
t2 = (((), (), {'leaves_below': 2, 'label': 7}), ((), (),
	{'leaves_below': 2, 'label': 8}),
	{'leaves_below': 4, 'label': 6})
t3 = ((), (), {'leaves_below': 2, 'label': 5})
t4 = (t1,t3,{'leaves_below': 5, 'label': 2})
t = (t2,t4,{'leaves_below': 9, 'label': 1})

# Calculation of n choose j
# This version saves partial results for use later
nc_matrix = [] #stores the values of nchoose(n,j)
# -- note: order of indices is reversed
def nchoose_static(n,j,nc_matrix):
	if j>n: return 0
	if len(nc_matrix)<j+1:
		for i in range(len(nc_matrix),j+1):
			nc_matrix += [[]]
	if len(nc_matrix[j])<n+1:
		for i in range(len(nc_matrix[j]),j):
			nc_matrix[j]+=[0]
	if len(nc_matrix[j])==j:
		nc_matrix[j]+=[1]
	for i in range(len(nc_matrix[j]),n+1):
		nc_matrix[j]+=[nc_matrix[j][i-1]*i/(i-j)]
	return nc_matrix[j][n]

# dynamic programming version
def nchoose(n,j):
	return nchoose_static(n,j,nc_matrix) #nc_matrix acts as a static variable

# get the number of descendants of u and of all vertices on the
# path to the root (subroutine for rankprob(t,u))
def numDescendants(t,u):
	if t == ():
		return [False,False]
	if t[2]["label"]==u:
		return [True,[t[2]["leaves_below"]-1]]
	x = numDescendants(t[0],u)
	if x[0] == True:
		if t[1]==():
			n=0
		else:
			n = t[1][2]["leaves_below"]-1
		return [True,x[1]+[n]]
	y = numDescendants(t[1],u)
	if y[0] == True:
		if t[0]==():
			n=0
		else:
			n = t[0][2]["leaves_below"]-1
		return [True,y[1]+[n]]
	else:
		return [False,False]

# A version of rankprob which uses the function numDescendants
def rankprob(t,u):
	x = numDescendants(t,u)
	x = x[1]
	lhsm = x[0]
	k = len(x)
	start = 1
	end = 1
	rp = [0,1]
	step = 1
	while step < k:
		rhsm = x[step]
		newstart = start+1
		newend = end+rhsm+1
		rp2 = []
		for i in range(0,newend+1):
			rp2+=[0]
		for i in range(newstart,newend+1):
			q = max(0,i-1-end)
			for j in range(q,min(rhsm,i-2)+1):
				a = rp[i-j-1] * nchoose(lhsm + rhsm - (i-1),rhsm-j) * nchoose(i-2,j)
				rp2[i]+=a
		rp = rp2
		start = newstart
		end = newend
		lhsm = lhsm+rhsm+1
		step+=1
	tot = float(sum(rp))
	for i in range(0,len(rp)):
		rp[i] = rp[i]/tot
	return rp

# For tree "t" and vertex "u" calculate the
# expected rank and variance
def expectedrank(t,u):
	rp = rankprob(t,u)
	mu = 0
	sigma = 0
	for i in range(0,len(rp)):
		mu += i*rp[i]
		sigma += i*i*rp[i]
	return (mu,sigma-mu*mu)

# GCD - assumes positive integers as input
# (subroutine for compare(t,u,v))
def gcd(n,m):
	if n==m:
		return n
	if m>n:
		[n,m]=[m,n]
	i = n/m
	n = n-m*i
	if n==0:
		return m
	return gcd(m,n)

# Takes two large integers and attempts to divide them and give
# the float answer without overflowing
# (subroutine for compare(t,u,v))
# does this by first taking out the gcd
def gcd_divide(n,m):
	x = gcd(n,m)
	n = n/x
	m = m/x
	return n/float(m)

# returns the subtree rooted at the common ancestor of u and v
# (subroutine for compare(t,u,v))
# return
# True/False - have we found u yet
# True/False - have we found v yet
# the subtree - if we have found u and v
# the u half of the subtree
# the v half of the subtree
def subtree(t,u,v):
	if t == ():
		return [False,False,False,False,False]
	[a,b,c,x1,x2]=subtree(t[0],u,v)
	[d,e,f,y1,y2]=subtree(t[1],u,v)
	if (a and b):
		return [a,b,c,x1,x2]
	if (d and e):
		return [d,e,f,y1,y2]
	#
	x = (a or d or t[2]["label"]==u)
	y = (b or e  or t[2]["label"]==v)
	#
	t1 = False
	t2 = False
	#
	if a:
		t1 = x1
	if b:
		t2 = x2
	if d:
		t1 = y1
	if e:
		t2 = y2
	#
	if x and (not y):
		t1 = t
	elif y and (not x):
		t2 = t
	#
	if t[2]["label"]==u:
		t1 = t
	if t[2]["label"]==v:
		t2 = t
	return [x,y,t,t1,t2]

# Gives the probability that vertex labeled v is
# below vertex labeled u
def compare(t,u,v):	
	[a,b,c,d,e] = subtree(t,u,v)
	if not (a and b):
		print "This tree does not have those vertices!"
		return 0
	if (c[2]["label"]==u):
		return 1.0
	if (c[2]["label"]==v):
		return 0.0
	tu = d
	tv = e
	usize = d[2]["leaves_below"]-1
	vsize = e[2]["leaves_below"]-1
	x = rankprob(tu,u)
	y = rankprob(tv,v)
	for i in range(len(x),usize+2):
		x+=[0]
	xcumulative = [0]
	for i in range(1,len(x)):
		xcumulative+=[xcumulative[i-1]+x[i]]
	rp = [0]
	for i in range(1,len(y)):
		rp+=[0]
		for j in range(1,usize+1):
			a = y[i]*nchoose(i-1+j,j)*nchoose(vsize-i+usize-j, usize-j)*xcumulative[j]
			rp[i]+=a
	tot = nchoose(usize+vsize,vsize)
	return sum(rp)/float(tot)


result = compare(t4,5,4)
print result