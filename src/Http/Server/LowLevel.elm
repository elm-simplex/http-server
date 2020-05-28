effect module Http.Server.LowLevel where { command = MyCmd, subscription = MySub } exposing (subscribe, respond, HttpRequest, HttpResponse, HttpRequestId, HttpMethod(..))

{-| Http.Server.LowLevel is a low-level api for a web server. It's not intended to be used directly by developers, but through other libraries.

Url's can be parsed with `elm/url`. Routes can be matched likewise.

Http responder cmd's can be stored in the model and returned from the update function to out-of-order if needed, so it's possible to perform some other Cmd before responding.

The main entrypoints are the `subscribe` and `respond` functions.

@docs subscribe, respond, HttpRequest, HttpResponse, HttpRequestId

-}

import Task exposing (Task)
import Bytes exposing (Bytes)


type HttpMethod
  = Get
  | Head
  | Post
  | Put
  | Delete
  | Connect
  | Options
  | Trace
  | Patch


{-| HttpRequest models a http request. Use the `requestId` along with the `respond` function in this module to respond to a specific http request.
-}
type alias HttpRequest =
    { method : HttpMethod
    , host : String -- example.com, without port number
    , path : String -- /search?q=elm#results
    , headers : List ( String, String ) -- TODO: Dict String (List String)? -- TODO: normalize header names
    , body : Bytes
    , requestId : HttpRequestId
    }


{-| HttpResponse models a http response. Use the `requestId` from a HttpRequest along with the `respond` function in this module to respond to a specific http request.
-}
type alias HttpResponse =
    { status : Int
    , headers : List ( String, String )
    , body : Bytes
    , requestId : HttpRequestId
    }


{-| HttpRequestId is an opaque unique identifier representing a specific http request. It's used to identify which http request we want to send a response to. Sending a second response to the same HttpRequestId has no effect.
-}
type HttpRequestId
    = RequestId Int


type MySub msg
    = MySub (HttpRequest -> msg)


type MyCmd msg
    = MyCmd HttpResponse


{-| Subscribe to http requests. Basically, start up a web server.
-}
subscribe : (HttpRequest -> msg) -> Sub msg
subscribe tagger =
    subscription (MySub tagger)


{-| Respond to a http request. Responding more than once to the same HttpRequestId has no effect; only the first response counts.
-}
respond : HttpResponse -> Cmd msg
respond response =
    command (MyCmd response)


subMap : (a -> b) -> MySub a -> MySub b
subMap fn sub =
    case sub of
        MySub tagger ->
            MySub (fn << tagger)


cmdMap : (a -> b) -> MyCmd a -> MyCmd b
cmdMap _ cmd =
    case cmd of
        MyCmd tagger ->
            MyCmd tagger



-- MANAGER


init : Task Never ()
init =
    Task.succeed ()


onEffects :
    Platform.Router msg x
    -> List (MyCmd msg)
    -> List (MySub msg)
    -> state
    -> Platform.Task Never state
onEffects router mycmds mysubs state =
    Task.succeed state


onSelfMsg : Platform.Router msg x -> x -> () -> Task Never ()
onSelfMsg router selfMsg state =
    Task.succeed ()
