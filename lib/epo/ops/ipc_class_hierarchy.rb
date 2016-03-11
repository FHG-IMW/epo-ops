module Epo
  module Ops
    class IpcClassHierarchy
      Hierarchy = { 'A' => %w(A01 A21 A22 A23 A24 A41 A42 A43 A44 A45 A46 A47 A61 A62 A63 A99),
                    'A01' => %w(A01B A01C A01D A01F A01G A01H A01J A01K A01L A01M A01N A01P),
                    'A21' => %w(A21B A21C A21D),
                    'A22' => %w(A22B A22C),
                    'A23' => %w(A23B A23C A23D A23F A23G A23J A23K A23L A23N A23P),
                    'A24' => %w(A24B A24C A24D A24F),
                    'A41' => %w(A41B A41C A41D A41F A41G A41H),
                    'A42' => %w(A42B A42C),
                    'A43' => %w(A43B A43C A43D),
                    'A44' => %w(A44B A44C),
                    'A45' => %w(A45B A45C A45D A45F),
                    'A46' => %w(A46B A46D),
                    'A47' => %w(A47B A47C A47D A47F A47G A47H A47J A47K A47L),
                    'A61' => %w(A61B A61C A61D A61F A61G A61H A61J A61K A61L A61M A61N A61P A61Q),
                    'A62' => %w(A62B A62C A62D),
                    'A63' => %w(A63B A63C A63D A63F A63G A63H A63J A63K),
                    'A99' => ['A99Z'],
                    'B' => %w(B01 B02 B03 B04 B05 B06 B07 B08 B09 B21 B22 B23 B24 B25 B26 B27 B28 B29 B30 B31 B32 B33 B41 B42 B43 B44 B60 B61 B62 B63 B64 B65 B66 B67 B68 B81 B82 B99),
                    'B01' => %w(B01B B01D B01F B01J B01L),
                    'B02' => %w(B02B B02C),
                    'B03' => %w(B03B B03C B03D),
                    'B04' => %w(B04B B04C),
                    'B05' => %w(B05B B05C B05D),
                    'B06' => ['B06B'],
                    'B07' => %w(B07B B07C),
                    'B08' => ['B08B'],
                    'B09' => %w(B09B B09C),
                    'B21' => %w(B21B B21C B21D B21F B21G B21H B21J B21K B21L),
                    'B22' => %w(B22C B22D B22F),
                    'B23' => %w(B23B B23C B23D B23F B23G B23H B23K B23P B23Q),
                    'B24' => %w(B24B B24C B24D),
                    'B25' => %w(B25B B25C B25D B25F B25G B25H B25J),
                    'B26' => %w(B26B B26D B26F),
                    'B27' => %w(B27B B27C B27D B27F B27G B27H B27J B27K B27L B27M B27N),
                    'B28' => %w(B28B B28C B28D),
                    'B29' => %w(B29B B29C B29D B29K B29L),
                    'B30' => ['B30B'],
                    'B31' => %w(B31B B31C B31D B31F),
                    'B32' => ['B32B'],
                    'B33' => ['B33Y'],
                    'B41' => %w(B41B B41C B41D B41F B41G B41J B41K B41L B41M B41N),
                    'B42' => %w(B42B B42C B42D B42F),
                    'B43' => %w(B43K B43L B43M),
                    'B44' => %w(B44B B44C B44D B44F),
                    'B60' => %w(B60B B60C B60D B60F B60G B60H B60J B60K B60L B60M B60N B60P B60Q B60R B60S B60T B60V B60W),
                    'B61' => %w(B61B B61C B61D B61F B61G B61H B61J B61K B61L),
                    'B62' => %w(B62B B62C B62D B62H B62J B62K B62L B62M),
                    'B63' => %w(B63B B63C B63G B63H B63J),
                    'B64' => %w(B64B B64C B64D B64F B64G),
                    'B65' => %w(B65B B65C B65D B65F B65G B65H),
                    'B66' => %w(B66B B66C B66D B66F),
                    'B67' => %w(B67B B67C B67D),
                    'B68' => %w(B68B B68C B68F B68G),
                    'B81' => %w(B81B B81C),
                    'B82' => %w(B82B B82Y),
                    'B99' => ['B99Z'],
                    'C' => %w(C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C21 C22 C23 C25 C30 C40 C99),
                    'C01' => %w(C01B C01C C01D C01F C01G),
                    'C02' => ['C02F'],
                    'C03' => %w(C03B C03C),
                    'C04' => ['C04B'],
                    'C05' => %w(C05B C05C C05D C05F C05G),
                    'C06' => %w(C06B C06C C06D C06F),
                    'C07' => %w(C07B C07C C07D C07F C07G C07H C07J C07K),
                    'C08' => %w(C08B C08C C08F C08G C08H C08J C08K C08L),
                    'C09' => %w(C09B C09C C09D C09F C09G C09H C09J C09K),
                    'C10' => %w(C10B C10C C10F C10G C10H C10J C10K C10L C10M C10N),
                    'C11' => %w(C11B C11C C11D),
                    'C12' => %w(C12C C12F C12G C12H C12J C12L C12M C12N C12P C12Q C12R),
                    'C13' => %w(C13B C13K),
                    'C14' => %w(C14B C14C),
                    'C21' => %w(C21B C21C C21D),
                    'C22' => %w(C22B C22C C22F),
                    'C23' => %w(C23C C23D C23F C23G),
                    'C25' => %w(C25B C25C C25D C25F),
                    'C30' => ['C30B'],
                    'C40' => ['C40B'],
                    'C99' => ['C99Z'],
                    'D' => %w(D01 D02 D03 D04 D05 D06 D07 D21 D99),
                    'D01' => %w(D01B D01C D01D D01F D01G D01H),
                    'D02' => %w(D02G D02H D02J),
                    'D03' => %w(D03C D03D D03J),
                    'D04' => %w(D04B D04C D04D D04G D04H),
                    'D05' => %w(D05B D05C),
                    'D06' => %w(D06B D06C D06F D06G D06H D06J D06L D06M D06N D06P D06Q),
                    'D07' => ['D07B'],
                    'D21' => %w(D21B D21C D21D D21F D21G D21H D21J),
                    'D99' => ['D99Z'],
                    'E' => %w(E01 E02 E03 E04 E05 E06 E21 E99),
                    'E01' => %w(E01B E01C E01D E01F E01H),
                    'E02' => %w(E02B E02C E02D E02F),
                    'E03' => %w(E03B E03C E03D E03F),
                    'E04' => %w(E04B E04C E04D E04F E04G E04H),
                    'E05' => %w(E05B E05C E05D E05F E05G),
                    'E06' => %w(E06B E06C),
                    'E21' => %w(E21B E21C E21D E21F),
                    'E99' => ['E99Z'],
                    'F' => %w(F01 F02 F03 F04 F15 F16 F17 F21 F22 F23 F24 F25 F26 F27 F28 F41 F42 F99),
                    'F01' => %w(F01B F01C F01D F01K F01L F01M F01N F01P),
                    'F02' => %w(F02B F02C F02D F02F F02G F02K F02M F02N F02P),
                    'F03' => %w(F03B F03C F03D F03G F03H),
                    'F04' => %w(F04B F04C F04D F04F),
                    'F15' => %w(F15B F15C F15D),
                    'F16' => %w(F16B F16C F16D F16F F16G F16H F16J F16K F16L F16M F16N F16P F16S F16T),
                    'F17' => %w(F17B F17C F17D),
                    'F21' => %w(F21H F21K F21L F21S F21V F21W F21Y),
                    'F22' => %w(F22B F22D F22G),
                    'F23' => %w(F23B F23C F23D F23G F23H F23J F23K F23L F23M F23N F23Q F23R),
                    'F24' => %w(F24B F24C F24D F24F F24H F24J),
                    'F25' => %w(F25B F25C F25D F25J),
                    'F26' => ['F26B'],
                    'F27' => %w(F27B F27D),
                    'F28' => %w(F28B F28C F28D F28F F28G),
                    'F41' => %w(F41A F41B F41C F41F F41G F41H F41J),
                    'F42' => %w(F42B F42C F42D),
                    'F99' => ['F99Z'],
                    'G' => %w(G01 G02 G03 G04 G05 G06 G07 G08 G09 G10 G11 G12 G21 G99),
                    'G01' => %w(G01B G01C G01D G01F G01G G01H G01J G01K G01L G01M G01N G01P G01Q G01R G01S G01T G01V G01W),
                    'G02' => %w(G02B G02C G02F),
                    'G03' => %w(G03B G03C G03D G03F G03G G03H),
                    'G04' => %w(G04B G04C G04D G04F G04G G04R),
                    'G05' => %w(G05B G05D G05F G05G),
                    'G06' => %w(G06C G06D G06E G06F G06G G06J G06K G06M G06N G06Q G06T),
                    'G07' => %w(G07B G07C G07D G07F G07G),
                    'G08' => %w(G08B G08C G08G),
                    'G09' => %w(G09B G09C G09D G09F G09G),
                    'G10' => %w(G10B G10C G10D G10F G10G G10H G10K G10L),
                    'G11' => %w(G11B G11C),
                    'G12' => ['G12B'],
                    'G21' => %w(G21B G21C G21D G21F G21G G21H G21J G21K),
                    'G99' => ['G99Z'],
                    'H' => %w(H01 H02 H03 H04 H05 H99),
                    'H01' => %w(H01B H01C H01F H01G H01H H01J H01K H01L H01M H01P H01Q H01R H01S H01T),
                    'H02' => %w(H02B H02G H02H H02J H02K H02M H02N H02P H02S),
                    'H03' => %w(H03B H03C H03D H03F H03G H03H H03J H03K H03L H03M),
                    'H04' => %w(H04B H04H H04J H04K H04L H04M H04N H04Q H04R H04S H04W),
                    'H05' => %w(H05B H05C H05F H05G H05H H05K),
                    'H99' => ['H99Z'] }
    end
  end
end
