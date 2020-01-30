#include "interface.hpp"
#include "ggwp.hpp" // from flat
#include "lool.hpp" // from inteface
#include "class.hpp"

#if FLAT_VERSION != 10 || defined(NAME) // FLAT_VERSION is public; NAME is undefined here
void www() {
	static_assert(false);
}
#endif


int Hoy()
{
	auto mmm  = MMM(); // from interface
	auto pank = AClass();
	return pank.Hoy() + mmm.k8s;
}
