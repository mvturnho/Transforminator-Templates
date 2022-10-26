import javax.xml.parsers.DocumentBuilderFactory
import org.w3c.dom.Node
import org.xml.sax.InputSource
import javax.xml.xpath.*
import javax.xml.parsers.DocumentBuilderFactory
import groovy.json.JsonBuilder

filename = args[1]
//create dom from payload
DocumentBuilderFactory f = DocumentBuilderFactory.newInstance()
f.setNamespaceAware(true)
f.setValidating(false)
Node responseDOM = f.newDocumentBuilder().parse(new InputSource(new StringReader((String)payload)))
//get all tunnelcodes
def xpath = XPathFactory.newInstance().newXPath()
def nodes  = xpath.evaluate( "//tunnel/@code", responseDOM, XPathConstants.NODESET )

//create json structure
def list = []
def num = 1;
nodes.collect { 
    node -> {
        def map = [:]
        map["code"] =node.textContent
        map["color"] = "#93c47d"
        map["id"] = num++ 
        list << map
    }
}
def jsonBuilder = new JsonBuilder(list)
//save json to file
if(filename==null)
    filename = "tunnels.json"
new File(filename).write(jsonBuilder.toPrettyString(), "UTF-8")

return jsonBuilder.toPrettyString()