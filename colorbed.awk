# Makes a bed file from .cov file with color corresponding to percent
# methylation
# ==============================================================================
# Color is scico roma going from blue (0) to red (100) generated with the
# following R code:
#
# color <- scico::scico(101, palette = "roma", begin = 1, end = 0)
# color <- col2rgb(color)
# color <- apply(color, 2, function(x) paste(x[1], x[2], x[3], sep = ","))
#
# for (i in 1:length(color)) {
#   cat("color[\"", i - 1, "\"] = \"",  color[i], "\"\n",  sep = "")
# }
# ==============================================================================
# Parameters:
#   .cov file
#   sample = name of sample
# ==============================================================================
# Example:
#   awk -v name="myfilename" -f colorbed.awk myfile.cov > myfile.bed
# ==============================================================================

BEGIN {
    FS = "\t";
    OFS = "\t";
    print "track name=\""name"\" itemRgb=\"On\"";
    
    color["0"] = "26,51,153" # blue
    color["1"] = "28,55,154"
    color["2"] = "31,59,156"
    color["3"] = "32,63,157"
    color["4"] = "35,67,160"
    color["5"] = "36,70,161"
    color["6"] = "38,75,163"
    color["7"] = "39,78,164"
    color["8"] = "42,82,167"
    color["9"] = "43,86,168"
    color["10"] = "45,90,170"
    color["11"] = "47,95,172"
    color["12"] = "48,99,173"
    color["13"] = "50,103,176"
    color["14"] = "51,107,177"
    color["15"] = "54,111,179"
    color["16"] = "55,115,180"
    color["17"] = "57,120,183"
    color["18"] = "58,124,184"
    color["19"] = "61,128,186"
    color["20"] = "63,133,187"
    color["21"] = "64,137,190"
    color["22"] = "66,142,192"
    color["23"] = "68,146,193"
    color["24"] = "70,151,196"
    color["25"] = "71,155,197"
    color["26"] = "74,160,200"
    color["27"] = "76,164,201"
    color["28"] = "79,169,204"
    color["29"] = "81,173,205"
    color["30"] = "84,178,207"
    color["31"] = "88,184,209"
    color["32"] = "91,188,210"
    color["33"] = "95,193,213"
    color["34"] = "100,197,213"
    color["35"] = "105,202,215"
    color["36"] = "111,206,216"
    color["37"] = "117,211,217"
    color["38"] = "125,214,217"
    color["39"] = "133,218,217"
    color["40"] = "140,222,217"
    color["41"] = "148,225,218"
    color["42"] = "156,228,217"
    color["43"] = "163,229,216"
    color["44"] = "171,232,214"
    color["45"] = "179,233,213"
    color["46"] = "185,235,211"
    color["47"] = "192,235,209"
    color["48"] = "198,235,206"
    color["49"] = "204,237,204"
    color["50"] = "209,236,201" # light yellow
    color["51"] = "214,236,197"
    color["52"] = "218,236,193"
    color["53"] = "222,237,189"
    color["54"] = "224,235,184"
    color["55"] = "227,236,179"
    color["56"] = "228,234,174"
    color["57"] = "229,233,169"
    color["58"] = "229,233,164"
    color["59"] = "230,231,158"
    color["60"] = "229,229,152"
    color["61"] = "229,228,145"
    color["62"] = "227,225,138"
    color["63"] = "226,224,132"
    color["64"] = "224,220,125"
    color["65"] = "222,217,117"
    color["66"] = "219,213,110"
    color["67"] = "217,209,103"
    color["68"] = "214,204,95"
    color["69"] = "212,199,89"
    color["70"] = "208,194,82"
    color["71"] = "205,187,76"
    color["72"] = "202,182,71"
    color["73"] = "199,176,66"
    color["74"] = "196,170,62"
    color["75"] = "193,165,58"
    color["76"] = "191,159,55"
    color["77"] = "188,153,52"
    color["78"] = "186,148,50"
    color["79"] = "183,143,47"
    color["80"] = "180,138,44"
    color["81"] = "178,132,42"
    color["82"] = "175,127,40"
    color["83"] = "173,122,38"
    color["84"] = "170,116,35"
    color["85"] = "168,111,34"
    color["86"] = "165,106,31"
    color["87"] = "163,101,30"
    color["88"] = "160,96,27"
    color["89"] = "158,91,25"
    color["90"] = "155,86,23"
    color["91"] = "152,80,20"
    color["92"] = "150,74,18"
    color["93"] = "147,69,16"
    color["94"] = "144,63,14"
    color["95"] = "141,58,11"
    color["96"] = "139,52,9"
    color["97"] = "135,46,7"
    color["98"] = "133,40,5"
    color["99"] = "129,33,3"
    color["100"] = "126,25,0" # red
} {
    print $1, $2, $3, # location
        $1":"$2"-"$3, # name
        int($4 * 100), # percent methylated
        "+",
        $2, $3, # rectangle location
        color[int($4 * 100)] # color value
}
