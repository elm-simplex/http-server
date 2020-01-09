# Simplex Http-Server

This is a low-level api for a web server. It's not intended to be used directly by developers, but through other libraries. 

Url's can be parsed with `elm/url`. Routes can be matched likewise.

HttpRequestId's can be stored in the model and responded to out-of-order if needed, so it's possible to perform some other Cmd before responding.
