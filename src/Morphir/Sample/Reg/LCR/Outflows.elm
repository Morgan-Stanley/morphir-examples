{-
   Copyright 2020 Morgan Stanley

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-}


module Morphir.Sample.Reg.LCR.Outflows exposing (..)

-- import Dict exposing (Dict)

import Morphir.SDK.LocalDate exposing (LocalDate)
import Morphir.Sample.Reg.LCR.Basics exposing (..)
import Morphir.Sample.Reg.LCR.Counterparty exposing (..)
import Morphir.Sample.Reg.LCR.Flows exposing (..)
import Morphir.Sample.Reg.LCR.MaturityBucket exposing (..)
import Morphir.Sample.Reg.LCR.Rules exposing (..)


{-| The list of all rules pertaining to outlfows.
-}
outflowRules : (Flow -> Counterparty) -> LocalDate -> List (Rule Flow)
outflowRules counterparty t =
    [ Rule "32(a)(1)" 0.03 isRule32a1
    , Rule "32(a)(2)" 0.1 (isRule32a2 counterparty)
    , Rule "32(a)(3)" 0.2 (isRule32a3 counterparty)
    , Rule "32(a)(4)" 0.4 (isRule32a4 counterparty)
    , Rule "32(a)(5)" 0.4 (isRule32a5 counterparty)
    , Rule "32(b)" 1.0 isRule32b
    , Rule "32(c)" 0.2 isRule32c
    , Rule "32(d)" 0.1 isRule32d
    , Rule "32(e)" 0.0 isRule32e
    , Rule "32(f)" 0.0 isRule32f
    , Rule "32(g)(1)" 0.0 (isRule32g1 counterparty t)
    , Rule "32(g)(2)" 0.0 (isRule32g2 counterparty t)
    , Rule "32(g)(3)" 0.0 (isRule32g3 counterparty t)
    , Rule "32(g)(4)" 0.0 (isRule32g4 counterparty t)
    , Rule "32(g)(5)" 0.0 (isRule32g5 counterparty)
    , Rule "32(g)(6)" 0.0 (isRule32g6 counterparty)
    , Rule "32(g)(7)" 0.0 (isRule32g7 counterparty)
    , Rule "32(g)(8)" 0.0 (isRule32g8 counterparty)
    , Rule "32(g)(9)" 0.0 (isRule32g9 counterparty)
    , Rule "32(h)(3)" 0.05 (isRule32h3 counterparty)
    , Rule "32(h)(4)" 0.25 (isRule32h4 counterparty)
    , Rule "32(l)" 0.0 isRule32l
    , Rule "33(f)(1)(iii)" 0.0 (isRule33f1iii t)
    , Rule "33(f)(1)(iv)" 0.15 (isRule33f1iv t)
    ]



-- Rules broken out for (eventual) unit testing


isRule32a1 : Flow -> Bool
isRule32a1 flow =
    List.member flow.ruleCode [ [ "O", "D", "1" ], [ "O", "D", "2" ] ]
        && flow.insured
        == FDIC


isRule32a2 : (Flow -> Counterparty) -> Flow -> Bool
isRule32a2 counterparty flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    (List.member flow.ruleCode [ [ "O", "D", "1" ], [ "O", "D", "2" ] ]
        && List.member cpty.counterpartyType [ Retail, SmallBusiness ]
        && flow.insured
        /= FDIC
    )
        || (flow.ruleCode
                == [ "O", "D", "3" ]
                && List.member cpty.counterpartyType [ Retail, SmallBusiness ]
           )


isRule32a3 : (Flow -> Counterparty) -> Flow -> Bool
isRule32a3 counterparty flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    flow.ruleCode
        == [ "O", "D", "12" ]
        && List.member cpty.counterpartyType [ Retail, SmallBusiness ]
        && flow.insured
        == FDIC


isRule32a4 : (Flow -> Counterparty) -> Flow -> Bool
isRule32a4 counterparty flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    flow.ruleCode
        == [ "O", "D", "12" ]
        && List.member cpty.counterpartyType [ Retail, SmallBusiness ]
        && flow.insured
        /= FDIC


isRule32a5 : (Flow -> Counterparty) -> Flow -> Bool
isRule32a5 counterparty flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    List.member flow.ruleCode [ [ "O", "D", "13" ], [ "O", "W", "18" ] ]
        && List.member cpty.counterpartyType [ Retail, SmallBusiness ]


isRule32b : Flow -> Bool
isRule32b flow =
    List.member flow.ruleCode [ [ "O", "W", "1" ], [ "O", "W", "2" ], [ "O", "W", "4" ], [ "O", "O", "21" ] ]


isRule32c : Flow -> Bool
isRule32c flow =
    flow.ruleCode == [ "O", "O", "20" ]


isRule32d : Flow -> Bool
isRule32d flow =
    flow.ruleCode == [ "O", "O", "6" ]


isRule32e : Flow -> Bool
isRule32e flow =
    flow.ruleCode == [ "O", "O", "6" ]


isRule32f : Flow -> Bool
isRule32f flow =
    flow.ruleCode == [ "O", "O", "6" ]


isRule32g1 : (Flow -> Counterparty) -> LocalDate -> Flow -> Bool
isRule32g1 counterparty t flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow

        remainingDays : Int
        remainingDays =
            daysToMaturity t flow.maturityDate
    in
    flow.ruleCode
        == [ "O", "D", "7" ]
        && (cpty.counterpartyType == Retail || cpty.counterpartyType == SmallBusiness)
        && (0 < remainingDays && remainingDays <= 30)


isRule32g2 : (Flow -> Counterparty) -> LocalDate -> Flow -> Bool
isRule32g2 counterparty t flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    flow.ruleCode
        == [ "O", "D", "7" ]
        && (cpty.counterpartyType == Retail || cpty.counterpartyType == SmallBusiness)
        && daysToMaturity t flow.maturityDate
        <= 30


isRule32g3 : (Flow -> Counterparty) -> LocalDate -> Flow -> Bool
isRule32g3 counterparty t flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    flow.ruleCode
        == [ "O", "D", "7" ]
        && (cpty.counterpartyType == Retail || cpty.counterpartyType == SmallBusiness)
        && daysToMaturity t flow.maturityDate
        == 0
        && flow.insured
        == FDIC


isRule32g4 : (Flow -> Counterparty) -> LocalDate -> Flow -> Bool
isRule32g4 counterparty t flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    flow.ruleCode
        == [ "O", "D", "7" ]
        && (cpty.counterpartyType == Retail || cpty.counterpartyType == SmallBusiness)
        && daysToMaturity t flow.maturityDate
        == 0
        && flow.insured
        /= FDIC


isRule32g5 : (Flow -> Counterparty) -> Flow -> Bool
isRule32g5 counterparty flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    flow.ruleCode
        == [ "O", "D", "11" ]
        && (cpty.counterpartyType == Retail || cpty.counterpartyType == SmallBusiness)
        && flow.insured
        == FDIC


isRule32g6 : (Flow -> Counterparty) -> Flow -> Bool
isRule32g6 counterparty flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    flow.ruleCode
        == [ "O", "D", "11" ]
        && (cpty.counterpartyType == Retail || cpty.counterpartyType == SmallBusiness)
        && flow.insured
        /= FDIC


isRule32g7 : (Flow -> Counterparty) -> Flow -> Bool
isRule32g7 counterparty flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    flow.ruleCode
        == [ "O", "D", "8" ]
        && (cpty.counterpartyType == Retail || cpty.counterpartyType == SmallBusiness)
        && flow.insured
        == FDIC


isRule32g8 : (Flow -> Counterparty) -> Flow -> Bool
isRule32g8 counterparty flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    flow.ruleCode
        == [ "O", "D", "9" ]
        && (cpty.counterpartyType == Retail || cpty.counterpartyType == SmallBusiness)
        && flow.insured
        == FDIC


isRule32g9 : (Flow -> Counterparty) -> Flow -> Bool
isRule32g9 counterparty flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    (flow.ruleCode == [ "O", "D", "8" ] || flow.ruleCode == [ "O", "D", "9" ])
        && (cpty.counterpartyType == Retail || cpty.counterpartyType == SmallBusiness)
        && flow.insured
        /= FDIC



-- isRule32h1 : Flow -> Bool
-- isRule32h1 flow =
--     Debug.todo "Too many 32(h) rules to do..."
-- isRule32h2 : Flow -> Bool
-- isRule32h2 flow =
--     Debug.todo "Too many 32(h) rules to do..."


isRule32h3 : (Flow -> Counterparty) -> Flow -> Bool
isRule32h3 counterparty flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    flow.ruleCode
        == [ "O", "D", "4" ]
        && List.member cpty.counterpartyType
            [ NonFinancialCorporate
            , Sovereign
            , CentralBank
            , GovernmentSponsoredEntity
            , PublicSectorEntity
            , MultilateralDevelopmentBank
            , OtherSupranational
            , Bank
            , SupervisedNonBankFinancialEntity
            , DebtIssuingSpecialPurposeEntity
            , OtherFinancialEntity
            , Other
            ]
        && flow.insured
        == FDIC


isRule32h4 : (Flow -> Counterparty) -> Flow -> Bool
isRule32h4 counterparty flow =
    let
        cpty : Counterparty
        cpty =
            counterparty flow
    in
    flow.ruleCode
        == [ "O", "D", "4" ]
        && List.member cpty.counterpartyType
            [ NonFinancialCorporate
            , Sovereign
            , CentralBank
            , GovernmentSponsoredEntity
            , PublicSectorEntity
            , MultilateralDevelopmentBank
            , OtherSupranational
            , Bank
            , SupervisedNonBankFinancialEntity
            , DebtIssuingSpecialPurposeEntity
            , OtherFinancialEntity
            , Other
            ]
        && flow.insured
        /= FDIC



-- isRule32h5 : Flow -> Bool
-- isRule32h5 flow =
--     Debug.todo "Too many 32(h) rules to do..."
-- isRule32i : Flow -> Bool
-- isRule32i flow =
--     Debug.todo "Too many 32(i) rules to do..."
-- isRule32j : Flow -> Bool
-- isRule32j flow =
--     Debug.todo "Too many 32(j) rules to do..."
-- isRule32k : Flow -> Bool
-- isRule32k flow =
--     Debug.todo "Too many 32(k) rules to do..."


isRule32l : Flow -> Bool
isRule32l flow =
    flow.ruleCode == [ "O", "O", "22" ]


isRule33f1iii : LocalDate -> Flow -> Bool
isRule33f1iii t flow =
    let
        days : Int
        days =
            daysToMaturity t flow.effectiveMaturityDate
    in
    List.member flow.ruleCode [ [ "I", "S", "1" ], [ "I", "S", "2" ], [ "I", "S", "5" ], [ "I", "S", "6" ], [ "I", "S", "7" ] ]
        && flow.assetType
        == Level1Assets
        && (0 < days && days <= 30)


isRule33f1iv : LocalDate -> Flow -> Bool
isRule33f1iv t flow =
    let
        days : Int
        days =
            daysToMaturity t flow.effectiveMaturityDate
    in
    List.member flow.ruleCode [ [ "I", "S", "1" ], [ "I", "S", "2" ], [ "I", "S", "5" ], [ "I", "S", "6" ], [ "I", "S", "7" ] ]
        && flow.assetType
        == Level2aAssets
        && (0 < days && days <= 30)
