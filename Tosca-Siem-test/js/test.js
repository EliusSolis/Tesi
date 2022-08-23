const traversal = require('tosca.lib.traversal');
const tosca = require('tosca.lib.utils');




traversal.coerce();

let tf = '';
writeProvider();

// ciclo for per ogni nodo
for (let id in clout.vertexes) {
	let vertex = clout.vertexes[id];
    if (tosca.isTosca(vertex, 'NodeTemplate')) {
        tf += convert(vertex);
    }
}

puccini.write(tf);

function writeProvider(){   // scrive prime righe necessarie per tf
    tf += 'terraform {\nrequired_providers {\ndocker = {\nsource  = "kreuzwerker/docker"\nversion = "~> 2.13.0"\n}\n}\n}\n\nprovider "docker" {}\n\n';
}


function convert(node){  // dato un nodo tosca ritorna la stringa tf equivalente
    for (let name in node.properties.types) {
        switch (name){
        case 'terraform_network':
            return convertNetwork(node);
            break
        case "terraform_host":
            return convertHost(node);
            break;
        }
    }

    function convertHost(node){
        return 'Host qui \n';
    }

    function convertNetwork(node){
        let properties = node.properties
        let s= '';
        s += 'resource "docker_network" ' + properties['name'] + '{\n';

        for (let p in properties.properties){
            let propertie = properties.properties[p];
            s += p +' = ';
            if (typeof propertie === "string"){
                s+= '"'+propertie+'"';
            }else{
                s += propertie;
            }
            s += '\n';
        }

        s += 'ipam_config {\n'
        for (let p in properties.attributes){

            let propertie = properties.attributes[p];
            if (!propertie || p === 'state'){
                continue;
            }
            s += p +' = ';
            if (typeof propertie === "string"){
                s+= '"'+propertie+'"';
            }else{
                s += propertie;
            }
            s += '\n';
        }
        s += '}\n';
        s += '}\n';
        return s;
    }

    return 'error'
}