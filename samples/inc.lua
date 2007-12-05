require"macro"

macro.define_simple("inc", "$1 = $1 + 1")

macro.define_simple("inc_e", "(function () $1 = $1 + 1; return $1 end)()")

