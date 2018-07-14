%% -*- coding: utf-8 -*-
%%%----------------------------------------------------------------------
%%% @author    YYChildren <YYChildren@gmail.com>
%%% @doc       查询地级市精度的IP库
%%% @end
%%% Created    2018-07-14 07:55:38
%%%----------------------------------------------------------------------

-module(edatx_city).
-author("YYChildren").

-export([init/1,find/2]).

-export_type([city/0]).

-type city() :: {binary(), non_neg_integer()}.

-spec init(DBFile :: string()) -> City :: city().
init(DBFile) ->
    {ok, Data} = file:read_file(DBFile),
    <<IndexSize:32, _/binary>> = Data,
    City = {Data, IndexSize},
    City.


-spec find(IP :: string() | non_neg_integer(), city()) -> [binary()] | false.
find(IP, {Data, IndexSize}) when erlang:is_integer(IP) ->
    Low = 0,
    High = (IndexSize - 262144 - 262148) div 9 - 1,
    find(Low, High, IP, {Data, IndexSize});
find(IP, City) when erlang:is_list(IP) ->
    case string:tokens(IP, ".") of
        IP2 = [_,_,_,_] ->
            <<IP3:32>> = << <<(erlang:list_to_integer(N))>> || N <- IP2>>,
            find(IP3, City);
        _ ->
            false
    end.

find(Low0, High0, Val, {Data, IndexSize}) ->
    Mid = (Low0 + High0) div 2,
    Pos = Mid * 9 + 262148,
    if Mid > 0 ->
        Pos1 = (Mid - 1) * 9 + 262148,
        <<_:Pos1/binary-unit:8, Start0:32,  _/binary>> = Data,
        Start = Start0 + 1;
    true ->
        Start = 0
    end,
    <<_:Pos/binary-unit:8, End:32, _/binary>> = Data,
    if Val < Start ->
        High = Mid - 1,
        find(Low0, High, Val, {Data, IndexSize});
    true ->
        if Val > End ->
            Low = Mid + 1,
            find(Low, High0, Val, {Data, IndexSize});
        true ->
            Pos2 = Pos + 4,
            <<_:Pos2/binary-unit:8, D4, D5, D6, L:16, _/binary>> = Data,
            <<Off:24>> = <<D6, D5, D4>>,
            Pos3 = Off - 262144 + IndexSize,
            <<_:Pos3/binary-unit:8, Tmp:L/binary-unit:8, _/binary>> = Data,
            binary:split(Tmp, [<<"\t">>], [global])
        end
    end.
