

# as a part of an experiment boxes were rr-arranged in 2021
# this file defines that layout

# PACKAGES, SETTINGS
  sapply(c('data.table', 'sdb', 'magrittr','stringr','here','glue', 'bib2', 'sf', 'ggplot2', 'ggrepel') ,
  require, character.only = TRUE, quietly = TRUE)

# new layout (o = original location, m = moved location)
    x = fread('o    m
    1   2
    4   3
    6   5
    7   8
    9   10
    11  25
    12  13
    14  15
    17  16
    18  19
    21  20
    24  23
    28  27
    30  29
    31  114
    32  33
    34  37
    35  58
    36  66
    38  39
    41  42
    43  45
    44  26
    46  57
    48  54
    49  50
    52  82
    55  56
    61  62
    63  40
    64  65
    68  67
    70  69
    71  72
    73  60
    74  59
    75  89
    76  88
    77  87
    78  79
    80  84
    81  83
    85  86
    96  95
    98  99
    100 94
    101 93
    102 92
    103 104
    106 107
    108 109
    111 110
    112 113
    116 115
    120 119
    123 122
    125 124
    126 127
    129 128
    130 131
    133 132
    134 117
    136 135
    138 137
    140 139
    142 141
    145 144
    147 146
    150 149
    152 151
    153 154
    155 175
    156 121
    157 148
    158 172
    160 159
    161 169
    162 143
    163 164
    165 166
    167 168
    176 177
    178 179
    180 174
    181 197
    182 173
    183 196
    184 185
    186 187
    188 189
    191 190
    193 192
    195 194
    199 198
    200 105
    201 118
    204 205
    206 207
    209 208
    211 210
    213 212
    214 215
    216 217
    219 220
    221 222
    223 203
    224 202
    225 51
    226 90
    228 227
    230 229
    231 218
    233 234
    236 235
    238 232
    239 240
    242 243
    244 171
    245 22
    246 91
    247 248
    251 250
    252 241
    254 253
    255 237
    256 257
    258 259
    261 260
    262 249
    263 264
    267 265
    266 53
    269 268
    271 270
    273 272
    274 275
    276 170
    277 47')

# new xy
    boxesxy2 = merge(boxesxy, x, by.x = 'box', by.y = 'o', sort = FALSE)[, .(box=  m, long, lat)]
    boxesxy2 = merge(boxesxy, boxesxy2, by = 'box', all.x  = TRUE, sort = FALSE, suffixes = c('', '_new'))
  
    boxesxy2[ !is.na(long_new), ':=' (long = long_new, lat = lat_new+20) ][, ':=' (long_new = NULL, lat_new = NULL)]

    boxesxy2 = boxesxy2[box != 97]

    usethis::use_data(boxesxy2, overwrite = TRUE)    

# test 
    boxesxy2[, p :=  fcase(lat < 200, 'a', lat >= 200 & lat < 400, 'b', default = 'c' )]
    s = st_as_sf(boxesxy2, coords = c('long', 'lat'))

    ggplot(s) + geom_sf_text(aes(label = box, color = p))

    require(ggforce)

    ggplot(s) + geom_sf_text(aes(label = box)) + 
    facet_wrap_paginate(~ p, ncol = 1, nrow = 1, page = 3)





