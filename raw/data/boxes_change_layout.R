

# as a part of an experiment boxes were rr-arranged in 2021
# this file defines that layout

# PACKAGES, SETTINGS
  sapply(c('data.table', 'sdb', 'magrittr','stringr','here','glue', 'bib2', 'sf', 'ggplot2', 'ggrepel') ,
  require, character.only = TRUE, quietly = TRUE)

# new layout and check order (o = original location, m = moved location)
    x = fread('o    m
                1   2
                35  58
                34  37
                4   3
                32  33
                31  114
                6   5
                7   8
                30  29
                28  27
                9   10
                11  25
                12  13
                24  23
                14  15
                17  16
                18  19
                21  20
                49  50
                48  54
                46  57
                44  26
                43  45
                61  62
                41  42
                63  40
                64  65
                38  39
                36  66
                98  99
                100 94
                101 93
                102 92
                103 104
                120 119
                106 107
                116 115
                108 109
                85  86
                111 110
                52  82
                81  83
                80  84
                55  56
                78  79
                77  87
                76  88
                75  89
                74  59
                73  60
                71  72
                70  69
                96  95
                68  67
                126 127
                125 124
                123 122
                129 128
                130 131
                133 132
                134 117
                136 135
                113 112
                138 137
                165 166
                140 139
                163 164
                142 141
                162 143
                161 169
                160 159
                144 145
                158 172
                147 146
                157 148
                156 121
                155 175
                150 149
                152 151
                153 154
                201 118
                200 105
                199 198
                204 205
                206 207
                219 220
                209 208
                211 210
                216 217
                214 215
                213 212
                191 190
                188 189
                167 168
                186 187
                193 192
                184 185
                195 194
                183 196
                182 173
                181 197
                180 174
                178 179
                176 177
                224 202
                223 203
                226 90
                221 222
                228 227
                242 243
                230 229
                231 218
                239 240
                238 232
                233 234
                236 235
                254 253
                255 237
                256 257
                273 272
                271 270
                258 259
                252 241
                251 250
                261 260
                262 249
                269 268
                263 264
                267 265
                274 275
                276 170
                277 47
                266 53
                246 91
                247 248
                244 171
                245 22
                225 51')

# new xy
    boxesxy2 = merge(boxesxy, x, by.x = 'box', by.y = 'o', sort = FALSE)[, .(box=  m, long, lat)]
    boxesxy2 = merge(boxesxy, boxesxy2, by = 'box', all.x  = TRUE, sort = FALSE, suffixes = c('', '_new'))
    boxesxy2[ !is.na(long_new), ':=' (long = long_new, lat = lat_new+20) ][, ':=' (long_new = NULL, lat_new = NULL, rowID = NULL)]
    boxesxy2 = boxesxy2[box != 97]

    # add order
    x[, i := .I]

    o = split(x, by = 'i')
    o = lapply(o, function(x) x[, i:= NULL])
    o = lapply(o, function(x) unclass(x)  %>% unlist  %>% c)
    o =  data.table(box = do.call(c, o) )
    o[, walk_order := .I]

    boxesxy2 = merge(boxesxy2, o, by = 'box')
    setorder(boxesxy2, walk_order)


    usethis::use_data(boxesxy2, overwrite = TRUE)    

# test 
    boxesxy2[, p :=  fcase(lat < 200, 'a', lat >= 200 & lat < 400, 'b', default = 'c' )]
    s = st_as_sf(boxesxy2, coords = c('long', 'lat'))

    ggplot(s) + geom_sf_text(aes(label = box, color = p))

    require(ggforce)

    ggplot(s) + geom_sf_text(aes(label = box)) + 
    facet_wrap_paginate(~ p, ncol = 1, nrow = 1, page = 3)





