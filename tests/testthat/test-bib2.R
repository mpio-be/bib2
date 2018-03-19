

context("Utils")

    test_that("yy2dbnam", {

    expect_equal( yy2dbnam ( year(Sys.time()) )  ,          "FIELD_BTatWESTERHOLZ" )
    expect_equal( yy2dbnam ( 2017 )  ,          "FIELD_2017_BTatWESTERHOLZ" )



    })

