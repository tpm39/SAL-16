
# Calculate the Integer Square Root of x

# Calculate res = iSqrt(x)
def iSqrt(x):
	if x < 0:
		print('Negative number ...')
		return

	if x == 0 or x == 1:
		return x

	# Do a binary search for floor(sqrt(x))
	start = 1
	end = x//2

	while start <= end:
		mid = (start + end)//2

		# x is a perfect square
		if mid * mid == x:
			return mid

		if mid * mid < x:
			start = mid + 1
			res = mid
		else:
			end = mid - 1

	return res

# Main
x = int(input('\nEnter x: '))

print(f'\nThe integer square root of {x} is {iSqrt(x)}\n')
