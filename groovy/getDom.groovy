import javax.xml.parsers.DocumentBuilderFactory

import org.w3c.dom.Node
import org.xml.sax.InputSource

def xml=args[1]

DocumentBuilderFactory f = DocumentBuilderFactory.newInstance()
f.setNamespaceAware(true)
f.setValidating(false)
Node responseDOM = f.newDocumentBuilder().parse(new InputSource(new StringReader((String)xml.data)))

return responseDOM.getDocumentElement()