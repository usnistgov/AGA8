cmake_minimum_required (VERSION 2.6)
project (AGA8)

add_library(detail SHARED Detail.cpp)
add_library(gerg SHARED GERG2008.cpp)
add_library(gross SHARED Gross.cpp)

add_executable(detail_test Detail_test.cpp)
target_link_libraries(detail_test detail)

include(CTest)
# does the application even run
add_test(NAME DetailRuns
    COMMAND detail_test
    )
