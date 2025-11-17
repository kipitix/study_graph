#include <greeting.hpp>

#include <userver/utest/utest.hpp>

using study_graph_userver::UserType;

UTEST(SayHelloTo, Basic) {
    EXPECT_EQ(study_graph_userver::SayHelloTo("Developer", UserType::kFirstTime), "Hello, Developer!\n");
    EXPECT_EQ(study_graph_userver::SayHelloTo({}, UserType::kFirstTime), "Hello, unknown user!\n");

    EXPECT_EQ(study_graph_userver::SayHelloTo("Developer", UserType::kKnown), "Hi again, Developer!\n");
    EXPECT_EQ(study_graph_userver::SayHelloTo({}, UserType::kKnown), "Hi again, unknown user!\n");
}