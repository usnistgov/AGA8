cmake_minimum_required (VERSION 2.6)
project (AGA8)

add_library(detail SHARED Detail.cpp)
add_library(gerg SHARED GERG2008.cpp)
add_library(gross SHARED Gross.cpp)

add_executable(detail_test_01 Detail_test_01.cpp)
target_link_libraries(detail_test_01 detail)

include(CTest)
# Detail test gas 01
add_test(NAME Detail_Gas_01
    COMMAND detail_test_01
    )
