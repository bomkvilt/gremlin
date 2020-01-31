#include "gtest/gtest.h"
#include "class.hpp"

struct class_tests : public testing::Test
{

};

TEST_F(class_tests, ex)
{
	auto c = AClass();
	ASSERT_EQ(10, c.Hoy());
}
