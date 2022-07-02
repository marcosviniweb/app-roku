' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub init()
  print "UriHandler.brs - [init]"
  m.port = createObject("roMessagePort")
  m.top.observeField("request", m.port)
  m.top.functionName = "go"
  m.top.control = "RUN"
end sub



function addRequest(request as Object) as Boolean
  print "UriHandler.brs -  [addRequest]"
  if type(request) = "roAssociativeArray"
    context = request.context
  	if type(context) = "roSGNode"
      parameters = context.parameters
      if type(parameters)="roAssociativeArray"
        headers = parameters.headers
        method = parameters.method
      	uri = parameters.uri
        if type(uri) = "roString"
          urlXfer = createObject("roUrlTransfer")
          urlXfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
          urlXfer.InitClientCertificates()
          urlXfer.setUrl(uri)
          urlXfer.setPort(m.port)
          ' Add headers to the request
          for each header in headers
            urlXfer.AddHeader(header, headers.lookup(header))
          end for
          ' should transfer more stuff from parameters to urlXfer
          idKey = stri(urlXfer.getIdentity()).trim()
          'Make request based on request method
          ' AsyncGetToString returns false if the request couldn't be issued
          if method = "POST" or method = "PUT" or method = "DELETE"
            urlXfer.setRequest(method)
            ok = urlXfer.AsyncPostFromString("")
          else
            ok = urlXfer.AsyncGetToString()
          end if
          if ok then
            m.jobsById[idKey] = {
              context: request,
              xfer: urlXfer
            }
          else
            print "Error: request couldn't be issued"
          end if
  		    print "Initiating transfer '"; idkey; "' for URI '"; uri; "'"; " succeeded: "; ok
        else
          print "Error: invalid uri: "; uri
          m.top.numBadRequests++
  			end if
      else
        print "Error: parameters is the wrong type: " + type(parameters)
        return false
      end if
  	else
      print "Error: context is the wrong type: " + type(context)
  		return false
  	end if
  else
    print "Error: request is the wrong type: " + type(request)
    return false
  end if
  print "--------------------------------------------------------------------------"
  return true
end function
