#include <iostream>
#include "SQLiteCpp/SQLiteCpp.h"


#if TESTLIB != 16
void www() {
	static_assert(false);
}
#endif

void main()
{
	try
	{
		SQLite::Database("ex.sq3");
	}
	catch (const std::exception&)
	{
		std::cout << "ez game" << std::endl;
	}
}
