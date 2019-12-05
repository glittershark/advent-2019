:- module day1.
:- interface.
:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.
:- import_module list.
:- use_module exception.
:- import_module string.
:- import_module float.
:- import_module int.
:- import_module solutions.

:- func fuel_required(float) = int is det.
fuel_required(Mass) = Fuel :-
    Fuel = floor_to_int(Mass / 3.0) - 2.


:- pred all_fuel_required(list(float)::in, int::out) is det.
all_fuel_required(Masses, Fuel) :-
    list.map((pred(M::in, F::out) is det :- F = fuel_required(M)),
        Masses, Fuels),
    list.foldl(
        (pred(X::in, Y::in, R::out) is det :- R = X + Y),
        Fuels, 0, Fuel).

:- pred usage(io::di, io::uo) is erroneous.
usage(!IO) :-
    io.write_string("Must specify a filename on the command line\n", !IO),
    io.set_exit_status(1, !IO),
    exception.throw(usage).

:- pred read_file_as_string(string::in, string::out, io::di, io::uo) is det.
read_file_as_string(Filename, Result, !IO) :-
    io.open_input(Filename, StreamRes, !IO),
    (
        if ok(Stream) = StreamRes
        then
            io.set_input_stream(Stream, Stdin, !IO),
            io.read_file_as_string(DataResult, !IO),
            (
                if ok(Res) = DataResult
                then Result = Res
                else usage(!IO)
            ),
            io.set_input_stream(Stdin, _, !IO)
        else usage(!IO)
    ).

:- pred handle_args(list(string)::in, io::di, io::uo) is det.
handle_args([Filename | []], !IO) :-
    read_file_as_string(Filename, Data, !IO),
    Lines = string.split_at_char('\n', Data),
    solutions((
        pred(Mass::out) is nondet :-
            list.member(Line, Lines),
            string.to_float(Line, Mass)
    ), Masses),
    all_fuel_required(Masses, Fuel),
    io.format("%d\n", [i(Fuel)], !IO).
handle_args([], !IO) :- usage(!IO).
handle_args([_ | [_ | _]], !IO) :- usage(!IO).

main(!IO) :-
    io.command_line_arguments(Args, !IO),
    handle_args(Args, !IO).
