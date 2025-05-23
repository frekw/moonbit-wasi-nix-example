///| This function is invoked with an incoming HTTP Request, and a resource
/// `response-outparam` which provides the capability to reply with an HTTP
/// Response. The response is sent by calling the `response-outparam.set`
/// method, which allows execution to continue after the response has been
/// sent. This enables both streaming to the response body, and performing other
/// work.
///
/// The implementor of this function must write a response to the
/// `response-outparam` before returning, or else the caller will respond
/// with an error on its behalf.
pub fn handle(
  request : @types.IncomingRequest,
  response_out : @types.ResponseOutparam
) -> Unit {
  let response = (match request.path_with_query() {
      None | Some("/") => make_response(b"Hello, World")
      _ => make_response(b"Not Found", status_code=404)
    })
    |> Ok
  response_out.set(response)
  ()
}

///|
fn make_response(
  body : Bytes,
  status_code~ : UInt = 200
) -> @types.OutgoingResponse {
  let response = @types.OutgoingResponse::outgoing_response(
    @types.Fields::fields(),
  )
  response
  .body()
  .unwrap()
  .write()
  .unwrap()
  .blocking_write_and_flush(FixedArray::from_array(body.to_array()))
  .unwrap()
  response.set_status_code(status_code).unwrap()
  response
}
