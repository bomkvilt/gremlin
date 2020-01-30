#include <iostream>

#if TESTLIB != 16
void www() {
	static_assert(false);
}
#endif

void main()
{
	std::cout << "ez game" << std::endl;
}
