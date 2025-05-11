cmake_minimum_required (VERSION 3.23)
project (AGA8)

if (CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    add_compile_options(-Wall -Wextra -Wno-unused-parameter)
elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    add_compile_options(-Wall -Wextra -Weverything -Wno-unsafe-buffer-usage -Wno-unused-parameter)
endif()

add_library(detail SHARED Detail.cpp)
set_target_properties(detail PROPERTIES PUBLIC_HEADER Detail.h)

add_library(gerg SHARED GERG2008.cpp)
set_target_properties(gerg PROPERTIES PUBLIC_HEADER GERG2008.h)

add_library(gross SHARED Gross.cpp)
set_target_properties(gross PROPERTIES PUBLIC_HEADER Gross.h)

install(TARGETS detail gerg gross
    LIBRARY DESTINATION lib/${PROJECT_NAME}
    PUBLIC_HEADER DESTINATION include/${PROJECT_NAME}
)

add_executable(Detail_test_01 Detail_test_01.cpp)
target_link_libraries(Detail_test_01 detail)

add_executable(GERG2008_test_01 GERG2008_test_01.cpp)
target_link_libraries(GERG2008_test_01 gerg)

add_executable(Gross_test_01 Gross_test_01.cpp)
target_link_libraries(Gross_test_01 gross)

include(CTest)
add_test(NAME Detail_test_01 COMMAND Detail_test_01)
add_test(NAME GERG2008_test_01 COMMAND GERG2008_test_01)
add_test(NAME Gross_test_01 COMMAND Gross_test_01)
