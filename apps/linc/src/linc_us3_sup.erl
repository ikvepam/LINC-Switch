%%%-----------------------------------------------------------------------------
%%% Use is subject to License terms.
%%% @copyright (C) 2012 FlowForwarding.org
%%% @doc Supervisor module for the userspace switch implementation.
%%% @end
%%%-----------------------------------------------------------------------------
-module(linc_us3_sup).
-author("Erlang Solutions Ltd. <openflow@erlang-solutions.com>").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%%%-----------------------------------------------------------------------------
%%% API functions
%%%-----------------------------------------------------------------------------

-spec start_link() -> {ok, pid()} | ignore | {error, term()}.
start_link() ->
    {ok, _} = supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%%%-----------------------------------------------------------------------------
%%% Supervisor callbacks
%%%-----------------------------------------------------------------------------

init([]) ->
    PortSup = {linc_us3_port_sup, {linc_us3_port_sup, start_link, []},
               permanent, 5000, supervisor, [linc_us3_port_sup]},
    Sups = case application:get_env(linc, queues) of
               {ok, enabled} ->
                   QueueSup = {linc_us3_queue_sup,
                               {linc_us3_queue_sup, start_link, []},
                               permanent, 5000, supervisor,
                               [linc_us3_queue_sup]},
                   [QueueSup, PortSup];
               _ ->
                   [PortSup]
           end,
    {ok, {{one_for_one, 5, 10}, Sups}}.
