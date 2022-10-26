This templates uses the opentunnel export as an input file.
The file should be named configuration.xml. If you need a different name change this in the otdoc.tunnelvars:

exportfile=const://configuration.xml


You may change the options by chaning the values in the otdoc_options.json file
{
    "left_to_right": "true",
    "use_notes": "true",
    "add_content": "false",
    "add_mappings": "false",
    "add_certificates": "false",
    "add_organisations": "false"
}

The generated file is an uml file in PlantUML format. Install the plantuml extension for visualstudio code to generate the image from the UML

https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml



