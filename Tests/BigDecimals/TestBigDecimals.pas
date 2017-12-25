unit TestBigDecimals;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

// TODO: Write a program similar to the C# data generator, but this time for Java.
// Use similar data as the Decimal test program.

interface

uses
  TestFramework,
  System.Math,
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
  Velthuis.BigIntegers,
  Velthuis.BigDecimals,
  System.SysUtils;

type

  // Test methods for class BigDecimal

  TestBigDecimal = class(TTestCase)
  private
    Arguments: TArray<BigDecimal>;
    procedure Error(const Msg: string);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCreateValueScale;
    procedure TestCreateDouble;
    procedure TestCreateSingle;
    procedure TestCreateString;
    procedure TestCreateUInt64;
    procedure TestCreateInt64;
    procedure TestAdd;
    procedure TestSubtract;
    procedure TestMultiply;
    procedure TestDivide;
    procedure TestIntDivide;
    procedure TestPrecision;
    procedure TestNegative;
    procedure TestPositive;
    procedure TestRound;
    procedure TestFloor;
    procedure TestCeil;
    procedure TestImplicitDouble;
    procedure TestImplicitSingle;
    procedure TestImplicitString;
    procedure TestImplicitBigInteger;
    procedure TestImplicitUInt64;
    procedure TestExplicitDouble;
    procedure TestExplicitSingle;
    procedure TestExplicitString;
    procedure TestExplicitBigInteger;
    procedure TestExplicitUInt64;
    procedure TestDivideFunc;
    procedure TestNegate;
    procedure TestRemainder;
    procedure TestCompare;
    procedure TestMax;
    procedure TestMin;
    procedure TestTryParseSettings;
    procedure TestTryParseInvariant;
    procedure TestRoundTo;
    procedure TestRemoveTrailingZeros;
    procedure TestIntFrac;
    procedure TestTrunc;
    procedure TestToPlainString;
    procedure TestToString;
  end;

implementation

uses
  Velthuis.ExactFloatStrings, Velthuis.RandomNumbers, System.TypInfo, Velthuis.Loggers, Velthuis.FloatUtils;

{$INCLUDE 'BigDecimalTestData.inc'}

procedure TestBigDecimal.Error(const Msg: string);
begin
{$IFDEF MSWINDOWS}
  OutputDebugString(PChar(Msg));
{$ELSE}
  {$IFDEF CONSOLE}
    Writeln(ErrOutput, Msg);
  {$ENDIF}
{$ENDIF}
end;

procedure TestBigDecimal.SetUp;
var
  I: Integer;
begin
  BigDecimal.DefaultRoundingMode := CTestRoundingMode;
  BigDecimal.DefaultPrecision := CTestPrecision;
  SetLength(Arguments, Length(TestData));
  for I := Low(TestData) to High(TestData) do
    Arguments[I] := BigDecimal.Create(TestData[I]);
//  BreakOnFailures := False;
end;

procedure TestBigDecimal.TearDown;
begin
  Arguments := nil;
end;

procedure TestBigDecimal.TestCreateValueScale;
var
  A, B: BigDecimal;
  Scale: Integer;
  Value: BigInteger;
  I: Integer;
begin
  for I := 0 to High(Arguments) do
  begin
    A := Arguments[I];
    Scale := A.Scale;
    Value := A.UnscaledValue;
    B := BigDecimal.Create(Value, Scale);
    Check(A = B, Format('(%d) Create(%s,%d) = %s [%s,%d] (%s)', [I, Value.ToString(10), Scale, string(B), B.UnscaledValue.ToString, B.Scale, TestData[I]]));
  end;
end;

procedure TestBigDecimal.TestCreateDouble;
var
  I: Integer;
  D: Double;
  U: UInt64;
  Value: BigDecimal;
  S1: string;
  S2: string;
begin
  for I := 0 to High(DoubleValueResults) do
  begin
    U := DoubleValueResults[I];
    D := PDouble(@U)^;
    try
      Value := BigDecimal.Create(D);
    except
      on EInvalidArgument do
        Continue;
    end;
    S1 := ExactString(D);
    S2 := Value.ToPlainString;
    Check(S1 = S2, Format('S1 = %s, S2 = %s', [S1, S2]));
  end;
end;

procedure TestBigDecimal.TestCreateSingle;
var
  I: Integer;
  S: Single;
  U: UInt32;
  Value: BigDecimal;
  S1: string;
  S2: string;
begin
  for I := 0 to High(DoubleValueResults) do
  begin
    U := SingleValueResults[I];
    S := PSingle(@U)^;
    try
      Value := BigDecimal.Create(S);
    except
      on EInvalidArgument do
        Continue;
    end;
    S1 := ExactString(S);
    S2 := Value.ToPlainString;
    Check(S1 = S2, Format('S1 = %s, S2 = %s', [S1, S2]));
  end;
end;

const
  InvalidStrings: array[0..5, 0..1] of string =
  (
    ('1.2.333444',    '12.333444'),
    ('12ee77',        '123e77'),
    ('1.234e2.55',    '1.234e255'),
    ('1234.567-17',   '1234.567e-17'),
    ('1234.567d-17',  '1234.567e-17'),
    ('$1234.567',     '1234.567')
  );
  // Note: '1,200,300.45' is not invalid, it is equivalent to '1200300.45'. Thousands separators are ignored.

procedure TestBigDecimal.TestCreateString;

// Since most test routines already rely on the parsing of strings, this test only tests what happens
// if there is an error.

var
  I: Integer;
  SInvalid, SValid: string;
  ExceptionOnInvalidString,
  ExceptionOnValidString: Boolean;
  B: BigDecimal;
begin
  for I := 0 to High(InvalidStrings) do
  begin
    ExceptionOnValidString := False;
    ExceptionOnInvalidString := False;
    SInvalid := InvalidStrings[I, 0];
    SValid := InvalidStrings[I, 1];
    try
      B := BigDecimal.Create(SInvalid);
    except
      ExceptionOnInvalidString := True;
    end;
    try
      B := BigDecimal.Create(SValid);
    except
      ExceptionOnValidString := True;
    end;
    Check(ExceptionOnInvalidString and not ExceptionOnValidString, Format('(%d) Invalid = ''%s'', Valid = ''%s''', [I, SInvalid, SValid]));
  end;
end;

procedure TestBigDecimal.TestCreateUInt64;
var
  U: UInt64;
  B: BigInteger;
  V: BigDecimal;
  I: Integer;
  R: IRandom;
begin
  R := TRandom.Create(12345);
  for I := 1 to 100 do
  begin
    B := BigInteger.Create(64, R);
    U := B.AsUInt64;
    V := BigDecimal.Create(U);
    Check(V.UnscaledValue = B);
  end;
end;

procedure TestBigDecimal.TestCreateInt64;
var
  S: Int64;
  B: BigInteger;
  V: BigDecimal;
  I: Integer;
  R: IRandom;
  Sign: Integer;
begin
  Randomize;
  R := TRandom.Create(3456789);
  Sign := 2 * Random(2) - 1;
  for I := 1 to 100 do
  begin
    B := Sign * BigInteger.Create(63, R);
    S := B.AsInt64;
    V := BigDecimal.Create(S);
    Check(V.UnscaledValue = B);
  end;
end;

procedure TestBigDecimal.TestAdd;
var
  A, B, C, D: BigDecimal;
  SD: string;
  N, I, J: Integer;
begin
  N := 0;
  for I := 0 to High(Arguments) do
  begin
    A := Arguments[I];
    for J := 0 to High(Arguments) do
    begin
      B := Arguments[J];
      C := A + B;
      SD := AddResults[N].val;
      D := SD;
      Inc(N);
      Check(D = C, Format('(%d,%d,%d) %s + %s = %s (%s)', [I, J, N - 1, string(A), string(B), string(C), SD]));
    end;
  end;
end;

procedure TestBigDecimal.TestSubtract;
var
  A, B, C, D: BigDecimal;
  SD: string;
  N, I, J: Integer;
begin
  N := 0;
  for I := 0 to High(Arguments) do
  begin
    A := Arguments[I];
    for J := 0 to High(Arguments) do
    begin
      B := Arguments[J];
      C := A - B;
      SD := SubtractResults[N].val;
      D := SD;
      Check(D = C, Format('(%d,%d,%d) %s - %s = %s (%s)', [I, J, N, string(A), string(B), string(C), SD]));
      Inc(N);
    end;
  end;
end;

procedure TestBigDecimal.TestMultiply;
var
  A, B, C, D: BigDecimal;
  SD: string;
  N, I, J: Integer;
begin
  N := 0;
  for I := 0 to High(Arguments) do
  begin
    A := Arguments[I];
    for J := 0 to High(Arguments) do
    begin
      B := Arguments[J];
      C := A * B;
      SD := MultiplyResults[N].val;
      D := SD;
      Inc(N);
      Check(D = C, Format('(%d,%d,%d) %s * %s = %s (%s)', [I, J, N - 1, string(A), string(B), string(C), SD]));
    end;
  end;
end;

procedure TestBigDecimal.TestPrecision;
var
  I, Scale, Precision: Integer;
begin
  for I := 0 to High(Arguments) do
  begin
    Scale := Arguments[I].Scale;
    Precision := Arguments[I].Precision;
    Check((Scale = AdditionalData[I].Scale) and
          (Precision = AdditionalData[I].Precision),
          Format('(%d) Argument = ''%s'', Scale = %d (%d), Precision = %d (%d)',
          [I, TestData[I], Scale, AdditionalData[I].Scale, Precision, AdditionalData[I].Precision]));
  end;
end;

function EqualsExact(const Left, Right: BigDecimal): Boolean;
begin
  Result := (Left.Scale = Right.Scale) and (Left.UnscaledValue = Right.UnscaledValue);
end;

procedure TestBigDecimal.TestDivide;
var
  A, B, C, D: BigDecimal;
  TR: TTestResult;
  SD: string;
  N, I, J: Integer;
begin
  N := 0;
  for I := 0 to High(Arguments) do
  begin
    A := Arguments[I];
    for J := 0 to High(Arguments) do
    begin
      B := Arguments[J];
      TR := DivideResults[N];
      Inc(N);
      try
        C := A / B;
      except
        on E: EZeroDivide do
        begin
          Check(TR.info = triDivideByZero, Format('(%d,%d,%d) Unexpected EZeroDivide exception occurred', [I, J, N - 1]));
          Continue;
        end;
        on E: Exception do
          Error('TestDivide: Unexpected ' + E.ClassName + ' exception: ''' + E.Message + '''');
      end;
      SD := TR.val;
      D := SD;
      Check(C = D, Format('(%d,%d,%d) %s / %s = %s (%s)', [I, J, N - 1, string(A), string(B), string(C), SD]));
    end;
  end;
end;

procedure TestBigDecimal.TestIntDivide;
var
  A, B, C, D: BigDecimal;
  TR: TTestResult;
  SD: string;
  N, I, J: Integer;
begin
  N := 0;
  for I := 0 to High(Arguments) do
  begin
    A := Arguments[I];
    for J := 0 to High(Arguments) do
    begin
      B := Arguments[J];
      TR := IntDivideResults[N];
      Inc(N);
      try
        C := A div B;
      except
        on E: EZeroDivide do
        begin
          Check(TR.info = triDivideByZero, Format('(%d,%d,%d) Unexpected EZeroDivide exception occurred', [I, J, N - 1]));
          Continue;
        end;
        on E: Exception do
          Error('TestDivide: Unexpected ' + E.ClassName + ' exception: ''' + E.Message + '''');
      end;
      SD := TR.val;
      D := SD;
      Check((C = D) and (C.Scale = D.Scale), Format('(%d,%d,%d) %s / %s = %s (%s)', [I, J, N - 1, string(A), string(B), string(C), SD]));
    end;
  end;
end;

procedure TestBigDecimal.TestNegative;
var
  I: Integer;
  Left, Right, Sum: BigDecimal;
begin
  for I := 0 to High(Arguments) do
  begin
    Left := Arguments[I];
    Right := -Left;
    Sum := Left + Right;
    Check(Sum.IsZero);
  end;
end;

procedure TestBigDecimal.TestPositive;
var
  I: Integer;
  Left, Right, Sum: BigDecimal;
begin
  for I := 0 to High(Arguments) do
  begin
    Left := Arguments[I];
    Right := +Left;
    Sum := Left - Right;
    Check(Sum.IsZero);
  end;
end;

procedure TestBigDecimal.TestRound;
var
  I: Integer;
  A: BigDecimal;
  J: BigDecimal.RoundingMode;
  L: Int64;
  Java: Int64;
  TI: Pointer;
begin
  L := -1;
  TI := TypeInfo(BigDecimal.RoundingMode);
  for I := 0 to High(Arguments) do
  begin
    A := Arguments[I];
    for J := Low(BigDecimal.RoundingMode) to High(BigDecimal.RoundingMode) do
    begin
      BigDecimal.DefaultRoundingMode := J;
      try
        L := Round(A);
      except
        on E: ERoundingNecessary do
          // Note: the value $BADC0FFEE is used to denote a Java ArithmeticException due to a rounding mode
          // of rmUnnecessary and the fact rounding was necessary anyway. That is the equivalent of a
          // ERoundingNecessaryException error in this unit.
          L := InvalidRoundValue;
        on E: EConvertError do
        begin
          // Note: this is the (silent) Java behaviour. In Delphi, I expect a proper EConvertError to occur,
          // but here, values are made compatible with Java output.
          L := Int64(UInt64(A.RoundTo(0).UnscaledValue));
        end;
      end;
      Java := Int64(RoundValueResults[I, J]);
      Check(L = Java, Format('(%d,%s) Round([%s, %d], %s) --> $%.16X ($%.16X)', [I, GetEnumName(TI, Ord(J)), A.UnscaledValue.ToString(16), A.Scale, GetEnumName(TI, Ord(J)), L, Java]));
    end;
  end;
end;

procedure TestBigDecimal.TestImplicitDouble;
var
  Value: BigDecimal;
  D: Double;
  I: Integer;
  L: Int64;
  SExact, SValue: string;
begin
  for I := 0 to High(DoubleValueResults) do
  begin
    L := Int64(UInt64(DoubleValueResults[I]));
    D := PDouble(@L)^;

    // Exclude out-of-range values.
    if IsPositiveInfinity(D) or IsNegativeInfinity(D) or IsNan(D) then
      Continue;

    Value := D;
    SValue := Value.ToPlainString;
    SExact := ExactString(D);
    Check(SValue = SExact, Format('(%d) L=%$.16X --> %s (%s)', [I, L, SExact, string(Value)]));
  end;
end;

procedure TestBigDecimal.TestImplicitSingle;
var
  Value: BigDecimal;
  S: Single;
  I: Integer;
  L: Int64;
  SExact, SValue: string;
begin
  for I := 0 to High(SingleValueResults) do
  begin
    L := Int32(UInt32(SingleValueResults[I]));
    S := PSingle(@L)^;

    // Exclude out-of-range values.
    if IsPositiveInfinity(S) or IsNegativeInfinity(S) or IsNan(S) then
      Continue;

    Value := S;
    SValue := Value.ToPlainString;
    SExact := ExactString(S);
    Check(SValue = SExact, Format('(%d) L=%$.8X --> %s (%s)', [I, L, SExact, string(Value)]));
  end;
end;

procedure TestBigDecimal.TestImplicitString;
var
  BigDec: BigDecimal;
  S: string;
  I: Integer;
  TestScale, Scale: Integer;
  TestValue, UnscaledValue: BigInteger;
  UnscaledEqual, ScaleEqual: Boolean;
begin
  for I := 0 to High(TestData) do
  begin
    S := TestData[I];
    BigDec := S;
    TestScale := ScalesAndUnscaledValues[I].Scale;
    TestValue := ScalesAndUnscaledValues[I].UnscaledValue;
    Scale := BigDec.Scale;
    UnscaledValue := BigDec.UnscaledValue; // $$RV: '-0.00' --> UnscaledValue = -0.
    UnscaledEqual := UnscaledValue = TestValue;
    ScaleEqual := Scale = TestScale;
    Check(ScaleEqual and UnscaledEqual, Format('(%d) ''%s'' --> [''%s'', %d] ([''%s'', %d])', [I, TestData[I], UnscaledValue.ToString(10), Scale, TestValue.ToString(10), TestScale]));
  end;
end;

procedure TestBigDecimal.TestImplicitBigInteger;
var
  Argument, NewValue: BigDecimal;
  Unscaled1, Unscaled2: BigInteger;
  I: Integer;
begin
  for I := 0 to High(Arguments) do
  begin
    Argument := Arguments[I];
    Unscaled1 := Argument.UnscaledValue;
    NewValue := Unscaled1;
    Unscaled2 := NewValue.UnscaledValue;
    Check((Unscaled1 = Unscaled2) and (NewValue.Scale = 0));
  end;
end;

procedure TestBigDecimal.TestImplicitUInt64;
var
  ReturnValue: BigDecimal;
  Unscaled: BigInteger;
  U: UInt64;
  I: Integer;
begin
  for I := 0 to High(DoubleValueResults) do
  begin
    U := DoubleValueResults[I];
    ReturnValue := U;
    Unscaled := ReturnValue.UnscaledValue;
    Check(U = Unscaled);
  end;
end;

procedure TestBigDecimal.TestExplicitDouble;
var
  A: BigDecimal;
  D: Double;
  L: UInt64;
  I: Integer;
begin
  for I := 0 to High(Arguments) do
  begin
    A := Arguments[I];
    D := Double(A);
    L := PUInt64(@D)^;
    Check(L = DoubleValueResults[I], Format('(%d) %70s --> %50.30f = $%.16X ($%.16X)', [I, string(A), D, L, DoubleValueResults[I]]));
  end;
end;

procedure TestBigDecimal.TestExplicitSingle;
type
  PUInt32 = ^UInt32;
var
  A: BigDecimal;
  S: Single;
  L: UInt32;
  I: Integer;
begin
  for I := 0 to High(Arguments) do
  begin
    A := Arguments[I];
    S := Single(A);
    L := PUInt32(@S)^;
    Check(L = SingleValueResults[I], Format('(%d) %70s --> %50.30f = $%.8X ($%.8X)', [I, string(A), S, L, SingleValueResults[I]]));
  end;
end;

procedure TestBigDecimal.TestExplicitString;
var
  S: string;
  Argument, NewValue: BigDecimal;
  I: Integer;
begin
  for I := 0 to High(Arguments) do
  begin
    Argument := Arguments[I];
    S := string(Argument);
    NewValue := S;
    Check(NewValue = Argument);
  end;
end;

procedure TestBigDecimal.TestExplicitBigInteger;
var
  Result1, Result2: BigInteger;
  Argument: BigDecimal;
  I: Integer;
begin
  for I := 0 to High(Arguments) do
  begin
    Argument := Arguments[I];
    Result1 := BigInteger(Argument);
    Result2 := Argument.RoundTo(0, rmDown).UnscaledValue;
    Check(Result1 = Result2);
  end;
end;

procedure TestBigDecimal.TestExplicitUInt64;
var
  ReturnValue: UInt64;
  Value: BigDecimal;
  I: Integer;
  ReturnValue2: BigInteger;
begin
  for I := 0 to High(Arguments) do
  begin
    Value := Arguments[I];
    ReturnValue := UInt64(Value);
    ReturnValue2 := Value.RoundTo(0, rmDown).UnscaledValue and High(UInt64);
    Check(ReturnValue = ReturnValue2, Format('UInt64(%s) = %19x (%s)', [string(Value), ReturnValue, string(ReturnValue2)]));
  end;
end;

procedure TestBigDecimal.TestDivideFunc;
var
  A, B, C, D: BigDecimal;
  TR: TTestResult;
  SD: string;
  N, I, J: Integer;
begin
  N := 0;
  for I := 0 to High(Arguments) do
  begin
    A := Arguments[I];
    for J := 0 to High(Arguments) do
    begin
      B := Arguments[J];
      TR := DivideResults[N];
      Inc(N);
      try
        C := BigDecimal.Divide(A, B);
      except
        on E: EZeroDivide do
        begin
          Check(TR.info = triDivideByZero, Format('(%d,%d,%d) Unexpected EZeroDivide exception occurred', [I, J, N - 1]));
          Continue;
        end;
        on E: Exception do
          Error('TestDivide: Unexpected ' + E.ClassName + ' exception: ''' + E.Message + '''');
      end;
      SD := TR.val;
      D := SD;
      Check(C = D, Format('(%d,%d,%d) %s / %s = %s (%s)', [I, J, N - 1, string(A), string(B), string(C), SD]));
    end;
  end;
end;

procedure TestBigDecimal.TestNegate;
var
  ReturnValue: BigDecimal;
  Value: BigDecimal;
  I: Integer;
begin
  for I := 0 to High(Arguments) do
  begin
    Value := Arguments[I];
    ReturnValue := -Value;
    Check(((Value.Sign <> ReturnValue.Sign) or (Value.Sign = 0)) and (Value.Abs = ReturnValue.Abs),
          Format('-(%s) = %s (%s)', [string(Value), string(ReturnValue), string(Value * BigDecimal(-1.0))]));
  end;
end;

procedure TestBigDecimal.TestRemainder;
var
  A, B, C, D: BigDecimal;
  TR: TTestResult;
  SD: string;
  N, I, J: Integer;
  ExceptionOccurred: Boolean;
begin
  ExceptionOccurred := False;
  N := 0;
  for I := 0 to High(Arguments) do
  begin
    A := Arguments[I];
    for J := 0 to High(Arguments) do
    begin
      B := Arguments[J];
      TR := RemainderResults[N];
      Inc(N);
      try
        C := BigDecimal.Remainder(A, B);
      except
        on E: EZeroDivide do
        begin
          ExceptionOccurred := True;
           Check(TR.info = triDivideByZero, Format('(%d,%d,%d) Unexpected EZeroDivide exception occurred: %s mod %s', [I, J, N - 1, string(A), string(B)]));
        end;
        on E: Exception do
        begin
          ExceptionOccurred := True;
          Check(TR.Info <> triOk, Format('(%d,%d,%d) TestDivide: Unexpected %s exception: ''%s''', [I, J, N - 1, E.ClassName, E.Message]));
        end;
      end;
      if TR.Info <> triOk then
        Check(ExceptionOccurred)
      else
      begin
        SD := TR.val;
        D := SD;
        Check(C = D, Format('(%d,%d,%d) %s mod %s = %s (%s)', [I, J, N - 1, string(A), string(B), string(C), SD]));
      end;
    end;
  end;
end;

procedure TestBigDecimal.TestFloor;
var
  I: Integer;
  A: BigDecimal;
  F: BigDecimal;
begin
  F := -1;
  for I := 0 to High(Arguments) do
  begin
    A := Arguments[I];
    F := A.Floor;
    Check((F <= A) and (F >= A - BigDecimal.One) and (F.Frac = BigDecimal.Zero),
          Format('(%d) %s.Floor = %s', [I, string(A), string(F)]));
  end;
end;

procedure TestBigDecimal.TestCeil;
var
  I: Integer;
  A: BigDecimal;
  C: BigDecimal;
begin
  C := -1;
  for I := 0 to High(Arguments) do
  begin
    A := Arguments[I];
    C := A.Ceil;
    Check((C >= A) and (C <= A + BigDecimal.One) and (C.Frac = BigDecimal.Zero),
          Format('(%d) %s.Ceil = %s', [I, string(A), string(C)]));
  end;
end;

procedure TestBigDecimal.TestCompare;
var
  I, J: Integer;
  ReturnValue: TValueSign;
  Right: BigDecimal;
  Left: BigDecimal;
begin
  for I := 0 to High(CompArguments) do
  begin
    Left := CompArguments[I];
    for J := 0 to High(CompArguments) do
    begin
      Right := CompArguments[J];
      ReturnValue := BigDecimal.Compare(Left, Right);
      Check(ReturnValue = CompResults[I, J], Format('(%d,%d) comparing %s and %s = %d (%d)', [I, J, string(Left), string(Right), ReturnValue, CompResults[I, J]]));
    end;
  end;
end;

procedure TestBigDecimal.TestMax;
var
  I, J: Integer;
  ReturnValue: BigDecimal;
  Right: BigDecimal;
  Left: BigDecimal;
begin
  for I := 0 to High(CompArguments) do
  begin
    Left := CompArguments[I];
    for J := 0 to High(CompArguments) do
    begin
      Right := CompArguments[J];
      ReturnValue := BigDecimal.Max(Left, Right);
      Check((ReturnValue >= Left) and (ReturnValue >= Right));
    end;
  end;
end;

procedure TestBigDecimal.TestMin;
var
  I, J: Integer;
  ReturnValue: BigDecimal;
  Right: BigDecimal;
  Left: BigDecimal;
begin
  for I := 0 to High(CompArguments) do
  begin
    Left := CompArguments[I];
    for J := 0 to High(CompArguments) do
    begin
      Right := CompArguments[J];
      ReturnValue := BigDecimal.Min(Left, Right);
      Check((ReturnValue <= Left) and (ReturnValue <= Right));
    end;
  end;
end;

procedure TestBigDecimal.TestTryParseInvariant;
var
  I: Integer;
  S0, S1, S2: string;
  Value: BigDecimal;
begin
  for I := 0 to High(TestData) do
  begin
    S0 := TestData[I];
    Value := S0;
    S1 := Value.ToPlainString;
    S2 := ToPlainStringResults[I].Val;
    Check(S1 = S2);
  end;
end;

procedure TestBigDecimal.TestTryParseSettings;
var
  I: Integer;
  S0, S1, S2: string;
  Settings: TFormatSettings;
  Value: BigDecimal;
begin
  Settings := TFormatSettings.Create('de_DE');
  Assert(Settings.DecimalSeparator = ',');
  for I := 0 to High(TestData) do
  begin
    S0 := StringReplace(TestData[I], '.', Settings.DecimalSeparator, [rfReplaceAll]);
    if not BigDecimal.TryParse(S0, Settings, Value) then
      Check(False, Format('Parsing %s was unsuccessful', [S0]));
    S1 := Value.ToPlainString;
    S2 := ToPlainStringResults[I].Val;
    Check(S1 = S2);
  end;
end;

procedure TestBigDecimal.TestRoundTo;
var
  Argument, ReturnValue, CheckValue: BigDecimal;
  I, Scale, N: Integer;
  Mode: BigDecimal.RoundingMode;
  TestResult: TTestResult;
  TestOK: Boolean;
begin
  N := 0;
  for I := 0 to High(Arguments) do
  begin
    Argument := Arguments[I];
    for Scale := 0 to High(TestDigits) do
    begin
      for Mode := Low(BigDecimal.RoundingMode) to High(BigDecimal.RoundingMode) do
      begin
        TestResult := RoundToResults[N];
        Inc(N);
        TestOK := False;
        if TestResult.Info = triOK then
        try
          CheckValue := BigDecimal(TestResult.Val);
          ReturnValue := Argument.RoundTo(TestDigits[Scale], Mode);
          TestOK := CheckValue = ReturnValue;
        except
          ReturnValue := '-1';
          TestOK := False; // no exception expected, so false.
        end
        else
        try
          ReturnValue := Argument.RoundTo(TestDigits[Scale], Mode);
        except
          on E: ERoundingNecessary do
          begin
            // This exception was expected, so true.
            TestOK := True;
            ReturnValue := '-1';
          end;
        end;
        Check(TestOK, Format('(%d,%d,%d,%d) %s.RoundTo(%d, %d) = %s (%s)',
                [I, Scale, Ord(Mode), N - 1, string(Argument), Scale, Ord(Mode), string(ReturnValue), TestResult.Val]));
      end;
    end;
  end;
end;

procedure TestBigDecimal.TestRemoveTrailingZeros;
var
  Argument, NewValue, CompValue: BigDecimal;
  PreferredScale: Integer;
  I, J, N: Integer;
begin
  N := 0;
  for I := 0 to High(Arguments) do
  begin
    Argument := Arguments[I];
    for J := 0 to High(TestDigits) do
    begin
      PreferredScale := TestDigits[J];
      NewValue := Argument.RemoveTrailingZeros(PreferredScale);
      CompValue := RemoveTrailingZeroResults[N].Val;
      Inc(N);
      Check(CompValue.Scale = NewValue.Scale, Format('(%d,%d) BigDecimal(%s).RemoveTrailingZeros(%d) --> %s (%s)', [I, J, string(Argument), TestDigits[J], string(NewValue), string(CompValue)]));
    end;
  end;
end;

procedure TestBigDecimal.TestIntFrac;
var
  IntValue, FracValue, NewValue: BigDecimal;
  Value: BigDecimal;
  I: Integer;
begin
  for I := 0 to High(Arguments) do
  begin
    Value := Arguments[I];
    IntValue := Value.Int;
    FracValue := Value.Frac;
    NewValue := IntValue + Value.Sign * FracValue;
    Check((BigDecimal.Zero <= FracValue) and (FracValue < BigDecimal.One) and ((Value.Sign = IntValue.Sign) or (IntValue.Sign = 0)) and (NewValue = Value),
          Format('%s --> %s, %s --> %s', [string(Value), string(IntValue), string(FracValue), string(NewValue)]));
  end;
end;

procedure TestBigDecimal.TestTrunc;
var
  ReturnValue: Int64;
  I: Integer;
  Value: BigDecimal;
  ExceptionOccurred: Boolean;
  CheckValue: Int64;
begin
  ReturnValue := 0;
  CheckValue := 0;
  ExceptionOccurred := False;
  for I := 0 to High(Arguments) do
  begin
    Value := Arguments[I];
    try
      ReturnValue := Value.Trunc;
    except
      ExceptionOccurred := True;
    end;
    try
      CheckValue := Value.Int.UnscaledValue.AsInt64;
    except
      Check(ExceptionOccurred);
    end;
    Check(ReturnValue = CheckValue);
  end;
end;

procedure TestBigDecimal.TestToPlainString;
var
  S0, S1: string;
  Value: BigDecimal;
  I: Integer;
begin
  for I := 0 to High(Arguments) do
  begin
    Value := Arguments[I];
    S0 := Value.ToPlainString;
    S1 := ToPlainStringResults[I].Val;
    Check(UpperCase(S0) = UpperCase(S1), Format('BigDecimal(''%s'').ToPlainString = %s (%s)', [TestData[I], S0, S1]));
  end;
end;

procedure TestBigDecimal.TestToString;
var
  S0, S1: string;
  Value: BigDecimal;
  I: Integer;
begin
  for I := 0 to High(Arguments) do
  begin
    Value := Arguments[I];
    S0 := Value.ToString;
    S1 := ToStringResults[I].Val;
    Check(UpperCase(S0) = UpperCase(S1), Format('BigDecimal(''%s'').ToString = %s (%s)', [TestData[I], S0, S1]));
  end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestBigDecimal.Suite);

end.


