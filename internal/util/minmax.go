package util

// MaxInt returns the not smaller of the 2 parameters
func MaxInt(var1, var2 int) int {
	if var1 > var2 {
		return var1
	}
	return var2
}

// MinInt returns the not bigger of the 2 parameters
func MinInt(var1, var2 int) int {
	if var1 < var2 {
		return var1
	}
	return var2
}
