cmake_minimum_required (VERSION 2.6)
project (AGA8)

add_library(detail SHARED Detail.cpp)
add_library(gerg SHARED GERG2008.cpp)
add_library(gross SHARED Gross.cpp)

add_executable(detail_test_01 Detail_test_01.cpp)
target_link_libraries(detail_test_01 detail)

add_executable(GERG2008_test_01 GERG2008_test_01.cpp)
target_link_libraries(GERG2008_test_01 gerg)

add_executable(Gross_test_01 Gross_test_01.cpp)
target_link_libraries(Gross_test_01 gross)

include(CTest)
# Detail test gas 01
add_test(NAME Detail_Gas_01
    COMMAND detail_test_01
    )

add_test(NAME GERG2008_Gas_01
    COMMAND GERG2008_test_01
    )

add_test(NAME Gross_Gas_01
    COMMAND Gross_test_01
    )
