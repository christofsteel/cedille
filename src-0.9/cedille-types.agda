----------------------------------------------------------------------------------
-- Types for parse trees
----------------------------------------------------------------------------------

module cedille-types where

open import lib
open import parse-tree

posinfo = string
alpha = string
alpha-bar-3 = string
alpha-range-1 = string
alpha-range-2 = string
kvar = string
kvar-bar-14 = string
kvar-star-15 = string
num = string
num-plus-5 = string
numone = string
numone-range-4 = string
numpunct = string
numpunct-bar-10 = string
numpunct-bar-6 = string
numpunct-bar-7 = string
numpunct-bar-8 = string
numpunct-bar-9 = string
var = string
var-bar-11 = string
var-bar-13 = string
var-star-12 = string

mutual

  data binder : Set where 
    All : binder
    Pi : binder

  data checkKind : Set where 
    Kind : kind → checkKind

  data cmd : Set where 
    CheckKind : kind → maybeCheckSuper → posinfo → cmd
    CheckTerm : term → maybeCheckType → cmdTerminator → posinfo → cmd
    CheckType : type → checkKind → cmdTerminator → posinfo → cmd
    DefKind : posinfo → kvar → maybeCheckSuper → kind → posinfo → cmd
    DefTerm : posinfo → var → maybeCheckType → term → cmdTerminator → posinfo → cmd
    DefType : posinfo → var → checkKind → type → cmdTerminator → posinfo → cmd
    Import : posinfo → var → posinfo → cmd
    Rec : posinfo → posinfo → var → decls → indices → ctordecls → type → udefs → posinfo → cmd

  data cmdTerminator : Set where 
    EraseOnly : cmdTerminator
    Hanf : cmdTerminator
    Hnf : cmdTerminator
    Normalize : cmdTerminator

  data cmds : Set where 
    CmdsNext : cmd → cmds → cmds
    CmdsStart : cmd → cmds

  data ctordecl : Set where 
    Ctordecl : posinfo → var → type → ctordecl

  data ctordecls : Set where 
    Ctordeclse : posinfo → ctordecls
    Ctordeclsne : ctordeclsne → ctordecls

  data ctordeclsne : Set where 
    CtordeclsneNext : ctordecl → ctordeclsne → ctordeclsne
    CtordeclsneStart : ctordecl → ctordeclsne

  data decl : Set where 
    Decl : posinfo → var → tk → posinfo → decl

  data decls : Set where 
    DeclsCons : decl → decls → decls
    DeclsNil : posinfo → decls

  data indices : Set where 
    Indicese : posinfo → indices
    Indicesne : decls → indices

  data kind : Set where 
    KndArrow : kind → kind → kind
    KndParens : posinfo → kind → posinfo → kind
    KndPi : posinfo → posinfo → var → tk → kind → kind
    KndTpArrow : type → kind → kind
    KndVar : posinfo → kvar → kind
    Star : posinfo → kind

  data lam : Set where 
    ErasedLambda : lam
    KeptLambda : lam

  data leftRight : Set where 
    Both : leftRight
    Left : leftRight
    Right : leftRight

  data liftingType : Set where 
    LiftArrow : liftingType → liftingType → liftingType
    LiftParens : posinfo → liftingType → posinfo → liftingType
    LiftPi : posinfo → var → type → liftingType → liftingType
    LiftStar : posinfo → liftingType
    LiftTpArrow : type → liftingType → liftingType

  data lterms : Set where 
    LtermsCons : term → lterms → lterms
    LtermsNil : posinfo → lterms

  data maybeAtype : Set where 
    Atype : type → maybeAtype
    NoAtype : maybeAtype

  data maybeCheckSuper : Set where 
    CheckSuper : maybeCheckSuper
    NoCheckSuper : maybeCheckSuper

  data maybeCheckType : Set where 
    NoCheckType : maybeCheckType
    Type : type → maybeCheckType

  data maybeErased : Set where 
    Erased : maybeErased
    NotErased : maybeErased

  data maybeKvarEq : Set where 
    KvarEq : posinfo → kvar → maybeKvarEq
    NoKvarEq : maybeKvarEq

  data maybeMinus : Set where 
    EpsHanf : maybeMinus
    EpsHnf : maybeMinus

  data maybeVarEq : Set where 
    NoVarEq : maybeVarEq
    VarEq : posinfo → var → maybeVarEq

  data optClass : Set where 
    NoClass : optClass
    SomeClass : tk → optClass

  data start : Set where 
    File : posinfo → cmds → posinfo → start

  data term : Set where 
    App : term → maybeErased → term → term
    AppTp : term → type → term
    Beta : posinfo → term
    Chi : posinfo → maybeAtype → term → term
    Delta : posinfo → term → term
    Epsilon : posinfo → leftRight → maybeMinus → term → term
    Hole : posinfo → term
    Lam : posinfo → lam → posinfo → var → optClass → term → term
    Parens : posinfo → term → posinfo → term
    PiInj : posinfo → num → term → term
    Rho : posinfo → term → term → term
    Sigma : posinfo → term → term
    Theta : posinfo → theta → term → lterms → term
    Var : posinfo → var → term

  data theta : Set where 
    Abstract : theta
    AbstractEq : theta
    AbstractVars : vars → theta

  data tk : Set where 
    Tkk : kind → tk
    Tkt : type → tk

  data type : Set where 
    Abs : posinfo → binder → posinfo → var → tk → type → type
    Iota : posinfo → var → optClass → type → type
    Lft : posinfo → posinfo → var → term → liftingType → type
    NoSpans : type → posinfo → type
    TpApp : type → type → type
    TpAppt : type → term → type
    TpArrow : type → type → type
    TpEq : term → term → type
    TpLambda : posinfo → posinfo → var → tk → type → type
    TpParens : posinfo → type → posinfo → type
    TpVar : posinfo → var → type

  data udef : Set where 
    Udef : posinfo → var → term → udef

  data udefs : Set where 
    Udefse : posinfo → udefs
    Udefsne : udefsne → udefs

  data udefsne : Set where 
    UdefsneNext : udef → udefsne → udefsne
    UdefsneStart : udef → udefsne

  data vars : Set where 
    VarsNext : var → vars → vars
    VarsStart : var → vars

-- embedded types:
aterm : Set
aterm = term
atype : Set
atype = type
lliftingType : Set
lliftingType = liftingType
lterm : Set
lterm = term
ltype : Set
ltype = type

data ParseTreeT : Set where
  parsed-binder : binder → ParseTreeT
  parsed-checkKind : checkKind → ParseTreeT
  parsed-cmd : cmd → ParseTreeT
  parsed-cmdTerminator : cmdTerminator → ParseTreeT
  parsed-cmds : cmds → ParseTreeT
  parsed-ctordecl : ctordecl → ParseTreeT
  parsed-ctordecls : ctordecls → ParseTreeT
  parsed-ctordeclsne : ctordeclsne → ParseTreeT
  parsed-decl : decl → ParseTreeT
  parsed-decls : decls → ParseTreeT
  parsed-indices : indices → ParseTreeT
  parsed-kind : kind → ParseTreeT
  parsed-lam : lam → ParseTreeT
  parsed-leftRight : leftRight → ParseTreeT
  parsed-liftingType : liftingType → ParseTreeT
  parsed-lterms : lterms → ParseTreeT
  parsed-maybeAtype : maybeAtype → ParseTreeT
  parsed-maybeCheckSuper : maybeCheckSuper → ParseTreeT
  parsed-maybeCheckType : maybeCheckType → ParseTreeT
  parsed-maybeErased : maybeErased → ParseTreeT
  parsed-maybeKvarEq : maybeKvarEq → ParseTreeT
  parsed-maybeMinus : maybeMinus → ParseTreeT
  parsed-maybeVarEq : maybeVarEq → ParseTreeT
  parsed-optClass : optClass → ParseTreeT
  parsed-start : start → ParseTreeT
  parsed-term : term → ParseTreeT
  parsed-theta : theta → ParseTreeT
  parsed-tk : tk → ParseTreeT
  parsed-type : type → ParseTreeT
  parsed-udef : udef → ParseTreeT
  parsed-udefs : udefs → ParseTreeT
  parsed-udefsne : udefsne → ParseTreeT
  parsed-vars : vars → ParseTreeT
  parsed-aterm : term → ParseTreeT
  parsed-atype : type → ParseTreeT
  parsed-lliftingType : liftingType → ParseTreeT
  parsed-lterm : term → ParseTreeT
  parsed-ltype : type → ParseTreeT
  parsed-posinfo : posinfo → ParseTreeT
  parsed-alpha : alpha → ParseTreeT
  parsed-alpha-bar-3 : alpha-bar-3 → ParseTreeT
  parsed-alpha-range-1 : alpha-range-1 → ParseTreeT
  parsed-alpha-range-2 : alpha-range-2 → ParseTreeT
  parsed-kvar : kvar → ParseTreeT
  parsed-kvar-bar-14 : kvar-bar-14 → ParseTreeT
  parsed-kvar-star-15 : kvar-star-15 → ParseTreeT
  parsed-num : num → ParseTreeT
  parsed-num-plus-5 : num-plus-5 → ParseTreeT
  parsed-numone : numone → ParseTreeT
  parsed-numone-range-4 : numone-range-4 → ParseTreeT
  parsed-numpunct : numpunct → ParseTreeT
  parsed-numpunct-bar-10 : numpunct-bar-10 → ParseTreeT
  parsed-numpunct-bar-6 : numpunct-bar-6 → ParseTreeT
  parsed-numpunct-bar-7 : numpunct-bar-7 → ParseTreeT
  parsed-numpunct-bar-8 : numpunct-bar-8 → ParseTreeT
  parsed-numpunct-bar-9 : numpunct-bar-9 → ParseTreeT
  parsed-var : var → ParseTreeT
  parsed-var-bar-11 : var-bar-11 → ParseTreeT
  parsed-var-bar-13 : var-bar-13 → ParseTreeT
  parsed-var-star-12 : var-star-12 → ParseTreeT
  parsed-anychar : ParseTreeT
  parsed-anychar-bar-16 : ParseTreeT
  parsed-anychar-bar-17 : ParseTreeT
  parsed-anychar-bar-18 : ParseTreeT
  parsed-anychar-bar-19 : ParseTreeT
  parsed-anychar-bar-20 : ParseTreeT
  parsed-anychar-bar-21 : ParseTreeT
  parsed-anychar-bar-22 : ParseTreeT
  parsed-anychar-bar-23 : ParseTreeT
  parsed-anychar-bar-24 : ParseTreeT
  parsed-anychar-bar-25 : ParseTreeT
  parsed-anychar-bar-26 : ParseTreeT
  parsed-anychar-bar-27 : ParseTreeT
  parsed-anychar-bar-28 : ParseTreeT
  parsed-anychar-bar-29 : ParseTreeT
  parsed-anychar-bar-30 : ParseTreeT
  parsed-anychar-bar-31 : ParseTreeT
  parsed-anychar-bar-32 : ParseTreeT
  parsed-anychar-bar-33 : ParseTreeT
  parsed-anychar-bar-34 : ParseTreeT
  parsed-anychar-bar-35 : ParseTreeT
  parsed-anychar-bar-36 : ParseTreeT
  parsed-anychar-bar-37 : ParseTreeT
  parsed-anychar-bar-38 : ParseTreeT
  parsed-anychar-bar-39 : ParseTreeT
  parsed-anychar-bar-40 : ParseTreeT
  parsed-anychar-bar-41 : ParseTreeT
  parsed-anychar-bar-42 : ParseTreeT
  parsed-anychar-bar-43 : ParseTreeT
  parsed-anychar-bar-44 : ParseTreeT
  parsed-anychar-bar-45 : ParseTreeT
  parsed-anychar-bar-46 : ParseTreeT
  parsed-anychar-bar-47 : ParseTreeT
  parsed-anychar-bar-48 : ParseTreeT
  parsed-anychar-bar-49 : ParseTreeT
  parsed-anychar-bar-50 : ParseTreeT
  parsed-anychar-bar-51 : ParseTreeT
  parsed-anychar-bar-52 : ParseTreeT
  parsed-anychar-bar-53 : ParseTreeT
  parsed-anychar-bar-54 : ParseTreeT
  parsed-anychar-bar-55 : ParseTreeT
  parsed-anychar-bar-56 : ParseTreeT
  parsed-anychar-bar-57 : ParseTreeT
  parsed-aws : ParseTreeT
  parsed-aws-bar-59 : ParseTreeT
  parsed-aws-bar-60 : ParseTreeT
  parsed-aws-bar-61 : ParseTreeT
  parsed-comment : ParseTreeT
  parsed-comment-star-58 : ParseTreeT
  parsed-ows : ParseTreeT
  parsed-ows-star-63 : ParseTreeT
  parsed-ws : ParseTreeT
  parsed-ws-plus-62 : ParseTreeT

------------------------------------------
-- Parse tree printing functions
------------------------------------------

posinfoToString : posinfo → string
posinfoToString x = "(posinfo " ^ x ^ ")"
alphaToString : alpha → string
alphaToString x = "(alpha " ^ x ^ ")"
alpha-bar-3ToString : alpha-bar-3 → string
alpha-bar-3ToString x = "(alpha-bar-3 " ^ x ^ ")"
alpha-range-1ToString : alpha-range-1 → string
alpha-range-1ToString x = "(alpha-range-1 " ^ x ^ ")"
alpha-range-2ToString : alpha-range-2 → string
alpha-range-2ToString x = "(alpha-range-2 " ^ x ^ ")"
kvarToString : kvar → string
kvarToString x = "(kvar " ^ x ^ ")"
kvar-bar-14ToString : kvar-bar-14 → string
kvar-bar-14ToString x = "(kvar-bar-14 " ^ x ^ ")"
kvar-star-15ToString : kvar-star-15 → string
kvar-star-15ToString x = "(kvar-star-15 " ^ x ^ ")"
numToString : num → string
numToString x = "(num " ^ x ^ ")"
num-plus-5ToString : num-plus-5 → string
num-plus-5ToString x = "(num-plus-5 " ^ x ^ ")"
numoneToString : numone → string
numoneToString x = "(numone " ^ x ^ ")"
numone-range-4ToString : numone-range-4 → string
numone-range-4ToString x = "(numone-range-4 " ^ x ^ ")"
numpunctToString : numpunct → string
numpunctToString x = "(numpunct " ^ x ^ ")"
numpunct-bar-10ToString : numpunct-bar-10 → string
numpunct-bar-10ToString x = "(numpunct-bar-10 " ^ x ^ ")"
numpunct-bar-6ToString : numpunct-bar-6 → string
numpunct-bar-6ToString x = "(numpunct-bar-6 " ^ x ^ ")"
numpunct-bar-7ToString : numpunct-bar-7 → string
numpunct-bar-7ToString x = "(numpunct-bar-7 " ^ x ^ ")"
numpunct-bar-8ToString : numpunct-bar-8 → string
numpunct-bar-8ToString x = "(numpunct-bar-8 " ^ x ^ ")"
numpunct-bar-9ToString : numpunct-bar-9 → string
numpunct-bar-9ToString x = "(numpunct-bar-9 " ^ x ^ ")"
varToString : var → string
varToString x = "(var " ^ x ^ ")"
var-bar-11ToString : var-bar-11 → string
var-bar-11ToString x = "(var-bar-11 " ^ x ^ ")"
var-bar-13ToString : var-bar-13 → string
var-bar-13ToString x = "(var-bar-13 " ^ x ^ ")"
var-star-12ToString : var-star-12 → string
var-star-12ToString x = "(var-star-12 " ^ x ^ ")"

mutual
  binderToString : binder → string
  binderToString (All) = "All" ^ ""
  binderToString (Pi) = "Pi" ^ ""

  checkKindToString : checkKind → string
  checkKindToString (Kind x0) = "(Kind" ^ " " ^ (kindToString x0) ^ ")"

  cmdToString : cmd → string
  cmdToString (CheckKind x0 x1 x2) = "(CheckKind" ^ " " ^ (kindToString x0) ^ " " ^ (maybeCheckSuperToString x1) ^ " " ^ (posinfoToString x2) ^ ")"
  cmdToString (CheckTerm x0 x1 x2 x3) = "(CheckTerm" ^ " " ^ (termToString x0) ^ " " ^ (maybeCheckTypeToString x1) ^ " " ^ (cmdTerminatorToString x2) ^ " " ^ (posinfoToString x3) ^ ")"
  cmdToString (CheckType x0 x1 x2 x3) = "(CheckType" ^ " " ^ (typeToString x0) ^ " " ^ (checkKindToString x1) ^ " " ^ (cmdTerminatorToString x2) ^ " " ^ (posinfoToString x3) ^ ")"
  cmdToString (DefKind x0 x1 x2 x3 x4) = "(DefKind" ^ " " ^ (posinfoToString x0) ^ " " ^ (kvarToString x1) ^ " " ^ (maybeCheckSuperToString x2) ^ " " ^ (kindToString x3) ^ " " ^ (posinfoToString x4) ^ ")"
  cmdToString (DefTerm x0 x1 x2 x3 x4 x5) = "(DefTerm" ^ " " ^ (posinfoToString x0) ^ " " ^ (varToString x1) ^ " " ^ (maybeCheckTypeToString x2) ^ " " ^ (termToString x3) ^ " " ^ (cmdTerminatorToString x4) ^ " " ^ (posinfoToString x5) ^ ")"
  cmdToString (DefType x0 x1 x2 x3 x4 x5) = "(DefType" ^ " " ^ (posinfoToString x0) ^ " " ^ (varToString x1) ^ " " ^ (checkKindToString x2) ^ " " ^ (typeToString x3) ^ " " ^ (cmdTerminatorToString x4) ^ " " ^ (posinfoToString x5) ^ ")"
  cmdToString (Import x0 x1 x2) = "(Import" ^ " " ^ (posinfoToString x0) ^ " " ^ (varToString x1) ^ " " ^ (posinfoToString x2) ^ ")"
  cmdToString (Rec x0 x1 x2 x3 x4 x5 x6 x7 x8) = "(Rec" ^ " " ^ (posinfoToString x0) ^ " " ^ (posinfoToString x1) ^ " " ^ (varToString x2) ^ " " ^ (declsToString x3) ^ " " ^ (indicesToString x4) ^ " " ^ (ctordeclsToString x5) ^ " " ^ (typeToString x6) ^ " " ^ (udefsToString x7) ^ " " ^ (posinfoToString x8) ^ ")"

  cmdTerminatorToString : cmdTerminator → string
  cmdTerminatorToString (EraseOnly) = "EraseOnly" ^ ""
  cmdTerminatorToString (Hanf) = "Hanf" ^ ""
  cmdTerminatorToString (Hnf) = "Hnf" ^ ""
  cmdTerminatorToString (Normalize) = "Normalize" ^ ""

  cmdsToString : cmds → string
  cmdsToString (CmdsNext x0 x1) = "(CmdsNext" ^ " " ^ (cmdToString x0) ^ " " ^ (cmdsToString x1) ^ ")"
  cmdsToString (CmdsStart x0) = "(CmdsStart" ^ " " ^ (cmdToString x0) ^ ")"

  ctordeclToString : ctordecl → string
  ctordeclToString (Ctordecl x0 x1 x2) = "(Ctordecl" ^ " " ^ (posinfoToString x0) ^ " " ^ (varToString x1) ^ " " ^ (typeToString x2) ^ ")"

  ctordeclsToString : ctordecls → string
  ctordeclsToString (Ctordeclse x0) = "(Ctordeclse" ^ " " ^ (posinfoToString x0) ^ ")"
  ctordeclsToString (Ctordeclsne x0) = "(Ctordeclsne" ^ " " ^ (ctordeclsneToString x0) ^ ")"

  ctordeclsneToString : ctordeclsne → string
  ctordeclsneToString (CtordeclsneNext x0 x1) = "(CtordeclsneNext" ^ " " ^ (ctordeclToString x0) ^ " " ^ (ctordeclsneToString x1) ^ ")"
  ctordeclsneToString (CtordeclsneStart x0) = "(CtordeclsneStart" ^ " " ^ (ctordeclToString x0) ^ ")"

  declToString : decl → string
  declToString (Decl x0 x1 x2 x3) = "(Decl" ^ " " ^ (posinfoToString x0) ^ " " ^ (varToString x1) ^ " " ^ (tkToString x2) ^ " " ^ (posinfoToString x3) ^ ")"

  declsToString : decls → string
  declsToString (DeclsCons x0 x1) = "(DeclsCons" ^ " " ^ (declToString x0) ^ " " ^ (declsToString x1) ^ ")"
  declsToString (DeclsNil x0) = "(DeclsNil" ^ " " ^ (posinfoToString x0) ^ ")"

  indicesToString : indices → string
  indicesToString (Indicese x0) = "(Indicese" ^ " " ^ (posinfoToString x0) ^ ")"
  indicesToString (Indicesne x0) = "(Indicesne" ^ " " ^ (declsToString x0) ^ ")"

  kindToString : kind → string
  kindToString (KndArrow x0 x1) = "(KndArrow" ^ " " ^ (kindToString x0) ^ " " ^ (kindToString x1) ^ ")"
  kindToString (KndParens x0 x1 x2) = "(KndParens" ^ " " ^ (posinfoToString x0) ^ " " ^ (kindToString x1) ^ " " ^ (posinfoToString x2) ^ ")"
  kindToString (KndPi x0 x1 x2 x3 x4) = "(KndPi" ^ " " ^ (posinfoToString x0) ^ " " ^ (posinfoToString x1) ^ " " ^ (varToString x2) ^ " " ^ (tkToString x3) ^ " " ^ (kindToString x4) ^ ")"
  kindToString (KndTpArrow x0 x1) = "(KndTpArrow" ^ " " ^ (typeToString x0) ^ " " ^ (kindToString x1) ^ ")"
  kindToString (KndVar x0 x1) = "(KndVar" ^ " " ^ (posinfoToString x0) ^ " " ^ (kvarToString x1) ^ ")"
  kindToString (Star x0) = "(Star" ^ " " ^ (posinfoToString x0) ^ ")"

  lamToString : lam → string
  lamToString (ErasedLambda) = "ErasedLambda" ^ ""
  lamToString (KeptLambda) = "KeptLambda" ^ ""

  leftRightToString : leftRight → string
  leftRightToString (Both) = "Both" ^ ""
  leftRightToString (Left) = "Left" ^ ""
  leftRightToString (Right) = "Right" ^ ""

  liftingTypeToString : liftingType → string
  liftingTypeToString (LiftArrow x0 x1) = "(LiftArrow" ^ " " ^ (liftingTypeToString x0) ^ " " ^ (liftingTypeToString x1) ^ ")"
  liftingTypeToString (LiftParens x0 x1 x2) = "(LiftParens" ^ " " ^ (posinfoToString x0) ^ " " ^ (liftingTypeToString x1) ^ " " ^ (posinfoToString x2) ^ ")"
  liftingTypeToString (LiftPi x0 x1 x2 x3) = "(LiftPi" ^ " " ^ (posinfoToString x0) ^ " " ^ (varToString x1) ^ " " ^ (typeToString x2) ^ " " ^ (liftingTypeToString x3) ^ ")"
  liftingTypeToString (LiftStar x0) = "(LiftStar" ^ " " ^ (posinfoToString x0) ^ ")"
  liftingTypeToString (LiftTpArrow x0 x1) = "(LiftTpArrow" ^ " " ^ (typeToString x0) ^ " " ^ (liftingTypeToString x1) ^ ")"

  ltermsToString : lterms → string
  ltermsToString (LtermsCons x0 x1) = "(LtermsCons" ^ " " ^ (termToString x0) ^ " " ^ (ltermsToString x1) ^ ")"
  ltermsToString (LtermsNil x0) = "(LtermsNil" ^ " " ^ (posinfoToString x0) ^ ")"

  maybeAtypeToString : maybeAtype → string
  maybeAtypeToString (Atype x0) = "(Atype" ^ " " ^ (typeToString x0) ^ ")"
  maybeAtypeToString (NoAtype) = "NoAtype" ^ ""

  maybeCheckSuperToString : maybeCheckSuper → string
  maybeCheckSuperToString (CheckSuper) = "CheckSuper" ^ ""
  maybeCheckSuperToString (NoCheckSuper) = "NoCheckSuper" ^ ""

  maybeCheckTypeToString : maybeCheckType → string
  maybeCheckTypeToString (NoCheckType) = "NoCheckType" ^ ""
  maybeCheckTypeToString (Type x0) = "(Type" ^ " " ^ (typeToString x0) ^ ")"

  maybeErasedToString : maybeErased → string
  maybeErasedToString (Erased) = "Erased" ^ ""
  maybeErasedToString (NotErased) = "NotErased" ^ ""

  maybeKvarEqToString : maybeKvarEq → string
  maybeKvarEqToString (KvarEq x0 x1) = "(KvarEq" ^ " " ^ (posinfoToString x0) ^ " " ^ (kvarToString x1) ^ ")"
  maybeKvarEqToString (NoKvarEq) = "NoKvarEq" ^ ""

  maybeMinusToString : maybeMinus → string
  maybeMinusToString (EpsHanf) = "EpsHanf" ^ ""
  maybeMinusToString (EpsHnf) = "EpsHnf" ^ ""

  maybeVarEqToString : maybeVarEq → string
  maybeVarEqToString (NoVarEq) = "NoVarEq" ^ ""
  maybeVarEqToString (VarEq x0 x1) = "(VarEq" ^ " " ^ (posinfoToString x0) ^ " " ^ (varToString x1) ^ ")"

  optClassToString : optClass → string
  optClassToString (NoClass) = "NoClass" ^ ""
  optClassToString (SomeClass x0) = "(SomeClass" ^ " " ^ (tkToString x0) ^ ")"

  startToString : start → string
  startToString (File x0 x1 x2) = "(File" ^ " " ^ (posinfoToString x0) ^ " " ^ (cmdsToString x1) ^ " " ^ (posinfoToString x2) ^ ")"

  termToString : term → string
  termToString (App x0 x1 x2) = "(App" ^ " " ^ (termToString x0) ^ " " ^ (maybeErasedToString x1) ^ " " ^ (termToString x2) ^ ")"
  termToString (AppTp x0 x1) = "(AppTp" ^ " " ^ (termToString x0) ^ " " ^ (typeToString x1) ^ ")"
  termToString (Beta x0) = "(Beta" ^ " " ^ (posinfoToString x0) ^ ")"
  termToString (Chi x0 x1 x2) = "(Chi" ^ " " ^ (posinfoToString x0) ^ " " ^ (maybeAtypeToString x1) ^ " " ^ (termToString x2) ^ ")"
  termToString (Delta x0 x1) = "(Delta" ^ " " ^ (posinfoToString x0) ^ " " ^ (termToString x1) ^ ")"
  termToString (Epsilon x0 x1 x2 x3) = "(Epsilon" ^ " " ^ (posinfoToString x0) ^ " " ^ (leftRightToString x1) ^ " " ^ (maybeMinusToString x2) ^ " " ^ (termToString x3) ^ ")"
  termToString (Hole x0) = "(Hole" ^ " " ^ (posinfoToString x0) ^ ")"
  termToString (Lam x0 x1 x2 x3 x4 x5) = "(Lam" ^ " " ^ (posinfoToString x0) ^ " " ^ (lamToString x1) ^ " " ^ (posinfoToString x2) ^ " " ^ (varToString x3) ^ " " ^ (optClassToString x4) ^ " " ^ (termToString x5) ^ ")"
  termToString (Parens x0 x1 x2) = "(Parens" ^ " " ^ (posinfoToString x0) ^ " " ^ (termToString x1) ^ " " ^ (posinfoToString x2) ^ ")"
  termToString (PiInj x0 x1 x2) = "(PiInj" ^ " " ^ (posinfoToString x0) ^ " " ^ (numToString x1) ^ " " ^ (termToString x2) ^ ")"
  termToString (Rho x0 x1 x2) = "(Rho" ^ " " ^ (posinfoToString x0) ^ " " ^ (termToString x1) ^ " " ^ (termToString x2) ^ ")"
  termToString (Sigma x0 x1) = "(Sigma" ^ " " ^ (posinfoToString x0) ^ " " ^ (termToString x1) ^ ")"
  termToString (Theta x0 x1 x2 x3) = "(Theta" ^ " " ^ (posinfoToString x0) ^ " " ^ (thetaToString x1) ^ " " ^ (termToString x2) ^ " " ^ (ltermsToString x3) ^ ")"
  termToString (Var x0 x1) = "(Var" ^ " " ^ (posinfoToString x0) ^ " " ^ (varToString x1) ^ ")"

  thetaToString : theta → string
  thetaToString (Abstract) = "Abstract" ^ ""
  thetaToString (AbstractEq) = "AbstractEq" ^ ""
  thetaToString (AbstractVars x0) = "(AbstractVars" ^ " " ^ (varsToString x0) ^ ")"

  tkToString : tk → string
  tkToString (Tkk x0) = "(Tkk" ^ " " ^ (kindToString x0) ^ ")"
  tkToString (Tkt x0) = "(Tkt" ^ " " ^ (typeToString x0) ^ ")"

  typeToString : type → string
  typeToString (Abs x0 x1 x2 x3 x4 x5) = "(Abs" ^ " " ^ (posinfoToString x0) ^ " " ^ (binderToString x1) ^ " " ^ (posinfoToString x2) ^ " " ^ (varToString x3) ^ " " ^ (tkToString x4) ^ " " ^ (typeToString x5) ^ ")"
  typeToString (Iota x0 x1 x2 x3) = "(Iota" ^ " " ^ (posinfoToString x0) ^ " " ^ (varToString x1) ^ " " ^ (optClassToString x2) ^ " " ^ (typeToString x3) ^ ")"
  typeToString (Lft x0 x1 x2 x3 x4) = "(Lft" ^ " " ^ (posinfoToString x0) ^ " " ^ (posinfoToString x1) ^ " " ^ (varToString x2) ^ " " ^ (termToString x3) ^ " " ^ (liftingTypeToString x4) ^ ")"
  typeToString (NoSpans x0 x1) = "(NoSpans" ^ " " ^ (typeToString x0) ^ " " ^ (posinfoToString x1) ^ ")"
  typeToString (TpApp x0 x1) = "(TpApp" ^ " " ^ (typeToString x0) ^ " " ^ (typeToString x1) ^ ")"
  typeToString (TpAppt x0 x1) = "(TpAppt" ^ " " ^ (typeToString x0) ^ " " ^ (termToString x1) ^ ")"
  typeToString (TpArrow x0 x1) = "(TpArrow" ^ " " ^ (typeToString x0) ^ " " ^ (typeToString x1) ^ ")"
  typeToString (TpEq x0 x1) = "(TpEq" ^ " " ^ (termToString x0) ^ " " ^ (termToString x1) ^ ")"
  typeToString (TpLambda x0 x1 x2 x3 x4) = "(TpLambda" ^ " " ^ (posinfoToString x0) ^ " " ^ (posinfoToString x1) ^ " " ^ (varToString x2) ^ " " ^ (tkToString x3) ^ " " ^ (typeToString x4) ^ ")"
  typeToString (TpParens x0 x1 x2) = "(TpParens" ^ " " ^ (posinfoToString x0) ^ " " ^ (typeToString x1) ^ " " ^ (posinfoToString x2) ^ ")"
  typeToString (TpVar x0 x1) = "(TpVar" ^ " " ^ (posinfoToString x0) ^ " " ^ (varToString x1) ^ ")"

  udefToString : udef → string
  udefToString (Udef x0 x1 x2) = "(Udef" ^ " " ^ (posinfoToString x0) ^ " " ^ (varToString x1) ^ " " ^ (termToString x2) ^ ")"

  udefsToString : udefs → string
  udefsToString (Udefse x0) = "(Udefse" ^ " " ^ (posinfoToString x0) ^ ")"
  udefsToString (Udefsne x0) = "(Udefsne" ^ " " ^ (udefsneToString x0) ^ ")"

  udefsneToString : udefsne → string
  udefsneToString (UdefsneNext x0 x1) = "(UdefsneNext" ^ " " ^ (udefToString x0) ^ " " ^ (udefsneToString x1) ^ ")"
  udefsneToString (UdefsneStart x0) = "(UdefsneStart" ^ " " ^ (udefToString x0) ^ ")"

  varsToString : vars → string
  varsToString (VarsNext x0 x1) = "(VarsNext" ^ " " ^ (varToString x0) ^ " " ^ (varsToString x1) ^ ")"
  varsToString (VarsStart x0) = "(VarsStart" ^ " " ^ (varToString x0) ^ ")"

ParseTreeToString : ParseTreeT → string
ParseTreeToString (parsed-binder t) = binderToString t
ParseTreeToString (parsed-checkKind t) = checkKindToString t
ParseTreeToString (parsed-cmd t) = cmdToString t
ParseTreeToString (parsed-cmdTerminator t) = cmdTerminatorToString t
ParseTreeToString (parsed-cmds t) = cmdsToString t
ParseTreeToString (parsed-ctordecl t) = ctordeclToString t
ParseTreeToString (parsed-ctordecls t) = ctordeclsToString t
ParseTreeToString (parsed-ctordeclsne t) = ctordeclsneToString t
ParseTreeToString (parsed-decl t) = declToString t
ParseTreeToString (parsed-decls t) = declsToString t
ParseTreeToString (parsed-indices t) = indicesToString t
ParseTreeToString (parsed-kind t) = kindToString t
ParseTreeToString (parsed-lam t) = lamToString t
ParseTreeToString (parsed-leftRight t) = leftRightToString t
ParseTreeToString (parsed-liftingType t) = liftingTypeToString t
ParseTreeToString (parsed-lterms t) = ltermsToString t
ParseTreeToString (parsed-maybeAtype t) = maybeAtypeToString t
ParseTreeToString (parsed-maybeCheckSuper t) = maybeCheckSuperToString t
ParseTreeToString (parsed-maybeCheckType t) = maybeCheckTypeToString t
ParseTreeToString (parsed-maybeErased t) = maybeErasedToString t
ParseTreeToString (parsed-maybeKvarEq t) = maybeKvarEqToString t
ParseTreeToString (parsed-maybeMinus t) = maybeMinusToString t
ParseTreeToString (parsed-maybeVarEq t) = maybeVarEqToString t
ParseTreeToString (parsed-optClass t) = optClassToString t
ParseTreeToString (parsed-start t) = startToString t
ParseTreeToString (parsed-term t) = termToString t
ParseTreeToString (parsed-theta t) = thetaToString t
ParseTreeToString (parsed-tk t) = tkToString t
ParseTreeToString (parsed-type t) = typeToString t
ParseTreeToString (parsed-udef t) = udefToString t
ParseTreeToString (parsed-udefs t) = udefsToString t
ParseTreeToString (parsed-udefsne t) = udefsneToString t
ParseTreeToString (parsed-vars t) = varsToString t
ParseTreeToString (parsed-aterm t) = termToString t
ParseTreeToString (parsed-atype t) = typeToString t
ParseTreeToString (parsed-lliftingType t) = liftingTypeToString t
ParseTreeToString (parsed-lterm t) = termToString t
ParseTreeToString (parsed-ltype t) = typeToString t
ParseTreeToString (parsed-posinfo t) = posinfoToString t
ParseTreeToString (parsed-alpha t) = alphaToString t
ParseTreeToString (parsed-alpha-bar-3 t) = alpha-bar-3ToString t
ParseTreeToString (parsed-alpha-range-1 t) = alpha-range-1ToString t
ParseTreeToString (parsed-alpha-range-2 t) = alpha-range-2ToString t
ParseTreeToString (parsed-kvar t) = kvarToString t
ParseTreeToString (parsed-kvar-bar-14 t) = kvar-bar-14ToString t
ParseTreeToString (parsed-kvar-star-15 t) = kvar-star-15ToString t
ParseTreeToString (parsed-num t) = numToString t
ParseTreeToString (parsed-num-plus-5 t) = num-plus-5ToString t
ParseTreeToString (parsed-numone t) = numoneToString t
ParseTreeToString (parsed-numone-range-4 t) = numone-range-4ToString t
ParseTreeToString (parsed-numpunct t) = numpunctToString t
ParseTreeToString (parsed-numpunct-bar-10 t) = numpunct-bar-10ToString t
ParseTreeToString (parsed-numpunct-bar-6 t) = numpunct-bar-6ToString t
ParseTreeToString (parsed-numpunct-bar-7 t) = numpunct-bar-7ToString t
ParseTreeToString (parsed-numpunct-bar-8 t) = numpunct-bar-8ToString t
ParseTreeToString (parsed-numpunct-bar-9 t) = numpunct-bar-9ToString t
ParseTreeToString (parsed-var t) = varToString t
ParseTreeToString (parsed-var-bar-11 t) = var-bar-11ToString t
ParseTreeToString (parsed-var-bar-13 t) = var-bar-13ToString t
ParseTreeToString (parsed-var-star-12 t) = var-star-12ToString t
ParseTreeToString parsed-anychar = "[anychar]"
ParseTreeToString parsed-anychar-bar-16 = "[anychar-bar-16]"
ParseTreeToString parsed-anychar-bar-17 = "[anychar-bar-17]"
ParseTreeToString parsed-anychar-bar-18 = "[anychar-bar-18]"
ParseTreeToString parsed-anychar-bar-19 = "[anychar-bar-19]"
ParseTreeToString parsed-anychar-bar-20 = "[anychar-bar-20]"
ParseTreeToString parsed-anychar-bar-21 = "[anychar-bar-21]"
ParseTreeToString parsed-anychar-bar-22 = "[anychar-bar-22]"
ParseTreeToString parsed-anychar-bar-23 = "[anychar-bar-23]"
ParseTreeToString parsed-anychar-bar-24 = "[anychar-bar-24]"
ParseTreeToString parsed-anychar-bar-25 = "[anychar-bar-25]"
ParseTreeToString parsed-anychar-bar-26 = "[anychar-bar-26]"
ParseTreeToString parsed-anychar-bar-27 = "[anychar-bar-27]"
ParseTreeToString parsed-anychar-bar-28 = "[anychar-bar-28]"
ParseTreeToString parsed-anychar-bar-29 = "[anychar-bar-29]"
ParseTreeToString parsed-anychar-bar-30 = "[anychar-bar-30]"
ParseTreeToString parsed-anychar-bar-31 = "[anychar-bar-31]"
ParseTreeToString parsed-anychar-bar-32 = "[anychar-bar-32]"
ParseTreeToString parsed-anychar-bar-33 = "[anychar-bar-33]"
ParseTreeToString parsed-anychar-bar-34 = "[anychar-bar-34]"
ParseTreeToString parsed-anychar-bar-35 = "[anychar-bar-35]"
ParseTreeToString parsed-anychar-bar-36 = "[anychar-bar-36]"
ParseTreeToString parsed-anychar-bar-37 = "[anychar-bar-37]"
ParseTreeToString parsed-anychar-bar-38 = "[anychar-bar-38]"
ParseTreeToString parsed-anychar-bar-39 = "[anychar-bar-39]"
ParseTreeToString parsed-anychar-bar-40 = "[anychar-bar-40]"
ParseTreeToString parsed-anychar-bar-41 = "[anychar-bar-41]"
ParseTreeToString parsed-anychar-bar-42 = "[anychar-bar-42]"
ParseTreeToString parsed-anychar-bar-43 = "[anychar-bar-43]"
ParseTreeToString parsed-anychar-bar-44 = "[anychar-bar-44]"
ParseTreeToString parsed-anychar-bar-45 = "[anychar-bar-45]"
ParseTreeToString parsed-anychar-bar-46 = "[anychar-bar-46]"
ParseTreeToString parsed-anychar-bar-47 = "[anychar-bar-47]"
ParseTreeToString parsed-anychar-bar-48 = "[anychar-bar-48]"
ParseTreeToString parsed-anychar-bar-49 = "[anychar-bar-49]"
ParseTreeToString parsed-anychar-bar-50 = "[anychar-bar-50]"
ParseTreeToString parsed-anychar-bar-51 = "[anychar-bar-51]"
ParseTreeToString parsed-anychar-bar-52 = "[anychar-bar-52]"
ParseTreeToString parsed-anychar-bar-53 = "[anychar-bar-53]"
ParseTreeToString parsed-anychar-bar-54 = "[anychar-bar-54]"
ParseTreeToString parsed-anychar-bar-55 = "[anychar-bar-55]"
ParseTreeToString parsed-anychar-bar-56 = "[anychar-bar-56]"
ParseTreeToString parsed-anychar-bar-57 = "[anychar-bar-57]"
ParseTreeToString parsed-aws = "[aws]"
ParseTreeToString parsed-aws-bar-59 = "[aws-bar-59]"
ParseTreeToString parsed-aws-bar-60 = "[aws-bar-60]"
ParseTreeToString parsed-aws-bar-61 = "[aws-bar-61]"
ParseTreeToString parsed-comment = "[comment]"
ParseTreeToString parsed-comment-star-58 = "[comment-star-58]"
ParseTreeToString parsed-ows = "[ows]"
ParseTreeToString parsed-ows-star-63 = "[ows-star-63]"
ParseTreeToString parsed-ws = "[ws]"
ParseTreeToString parsed-ws-plus-62 = "[ws-plus-62]"

------------------------------------------
-- Reorganizing rules
------------------------------------------

mutual

  {-# NO_TERMINATION_CHECK #-}
  norm-vars : (x : vars) → vars
  norm-vars x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-udefsne : (x : udefsne) → udefsne
  norm-udefsne x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-udefs : (x : udefs) → udefs
  norm-udefs x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-udef : (x : udef) → udef
  norm-udef x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-type : (x : type) → type
  norm-type (TpApp x1 (TpAppt x2 x3)) = (norm-type (TpAppt  (norm-type (TpApp  x1 x2) ) x3) )
  norm-type (TpApp x1 (TpApp x2 x3)) = (norm-type (TpApp  (norm-type (TpApp  x1 x2) ) x3) )
  norm-type x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-tk : (x : tk) → tk
  norm-tk x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-theta : (x : theta) → theta
  norm-theta x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-term : (x : term) → term
  norm-term (AppTp (App x1 x2 (Lam x3 x4 x5 x6 x7 x8)) x9) = (norm-term (App  x1 x2 (norm-term (Lam  x3 x4 x5 x6 x7 (norm-term (AppTp  x8 x9) )) )) )
  norm-term (AppTp (Lam x1 x2 x3 x4 x5 x6) x7) = (norm-term (Lam  x1 x2 x3 x4 x5 (norm-term (AppTp  x6 x7) )) )
  norm-term (App x1 x2 (AppTp x3 x4)) = (norm-term (AppTp  (norm-term (App  x1 x2 x3) ) x4) )
  norm-term (App (App x1 x2 (Lam x3 x4 x5 x6 x7 x8)) x9 x10) = (norm-term (App  x1 x2 (norm-term (Lam  x3 x4 x5 x6 x7 (norm-term (App  x8 x9 x10) )) )) )
  norm-term (App (Lam x1 x2 x3 x4 x5 x6) x7 x8) = (norm-term (Lam  x1 x2 x3 x4 x5 (norm-term (App  x6 x7 x8) )) )
  norm-term (App x1 x2 (App x3 x4 x5)) = (norm-term (App  (norm-term (App  x1 x2 x3) ) x4 x5) )
  norm-term x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-start : (x : start) → start
  norm-start x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-posinfo : (x : posinfo) → posinfo
  norm-posinfo x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-optClass : (x : optClass) → optClass
  norm-optClass x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-maybeVarEq : (x : maybeVarEq) → maybeVarEq
  norm-maybeVarEq x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-maybeMinus : (x : maybeMinus) → maybeMinus
  norm-maybeMinus x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-maybeKvarEq : (x : maybeKvarEq) → maybeKvarEq
  norm-maybeKvarEq x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-maybeErased : (x : maybeErased) → maybeErased
  norm-maybeErased x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-maybeCheckType : (x : maybeCheckType) → maybeCheckType
  norm-maybeCheckType x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-maybeCheckSuper : (x : maybeCheckSuper) → maybeCheckSuper
  norm-maybeCheckSuper x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-maybeAtype : (x : maybeAtype) → maybeAtype
  norm-maybeAtype x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-ltype : (x : ltype) → ltype
  norm-ltype x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-lterms : (x : lterms) → lterms
  norm-lterms x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-lterm : (x : lterm) → lterm
  norm-lterm x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-lliftingType : (x : lliftingType) → lliftingType
  norm-lliftingType x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-liftingType : (x : liftingType) → liftingType
  norm-liftingType (LiftArrow (LiftPi x1 x2 x3 x4) x5) = (norm-liftingType (LiftPi  x1 x2 x3 (norm-liftingType (LiftArrow  x4 x5) )) )
  norm-liftingType (LiftTpArrow (TpArrow x1 x2) x3) = (norm-liftingType (LiftTpArrow  x1 (norm-liftingType (LiftTpArrow  x2 x3) )) )
  norm-liftingType (LiftArrow (LiftTpArrow x1 x2) x3) = (norm-liftingType (LiftTpArrow  x1 (norm-liftingType (LiftArrow  x2 x3) )) )
  norm-liftingType (LiftArrow (LiftArrow x1 x2) x3) = (norm-liftingType (LiftArrow  x1 (norm-liftingType (LiftArrow  x2 x3) )) )
  norm-liftingType x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-leftRight : (x : leftRight) → leftRight
  norm-leftRight x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-lam : (x : lam) → lam
  norm-lam x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-kind : (x : kind) → kind
  norm-kind (KndArrow (KndPi x1 x2 x3 x4 x5) x6) = (norm-kind (KndPi  x1 x2 x3 x4 (norm-kind (KndArrow  x5 x6) )) )
  norm-kind (KndArrow (KndTpArrow x1 x2) x3) = (norm-kind (KndTpArrow  x1 (norm-kind (KndArrow  x2 x3) )) )
  norm-kind (KndArrow (KndArrow x1 x2) x3) = (norm-kind (KndArrow  x1 (norm-kind (KndArrow  x2 x3) )) )
  norm-kind x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-indices : (x : indices) → indices
  norm-indices x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-decls : (x : decls) → decls
  norm-decls x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-decl : (x : decl) → decl
  norm-decl x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-ctordeclsne : (x : ctordeclsne) → ctordeclsne
  norm-ctordeclsne x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-ctordecls : (x : ctordecls) → ctordecls
  norm-ctordecls x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-ctordecl : (x : ctordecl) → ctordecl
  norm-ctordecl x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-cmds : (x : cmds) → cmds
  norm-cmds x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-cmdTerminator : (x : cmdTerminator) → cmdTerminator
  norm-cmdTerminator x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-cmd : (x : cmd) → cmd
  norm-cmd x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-checkKind : (x : checkKind) → checkKind
  norm-checkKind x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-binder : (x : binder) → binder
  norm-binder x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-atype : (x : atype) → atype
  norm-atype x = x

  {-# NO_TERMINATION_CHECK #-}
  norm-aterm : (x : aterm) → aterm
  norm-aterm x = x

isParseTree : ParseTreeT → 𝕃 char → string → Set
isParseTree p l s = ⊤ {- this will be ignored since we are using simply typed runs -}

ptr : ParseTreeRec
ptr = record { ParseTreeT = ParseTreeT ; isParseTree = isParseTree ; ParseTreeToString = ParseTreeToString }
