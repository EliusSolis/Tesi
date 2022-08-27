const traversal = require('tosca.lib.traversal');
const tosca = require('tosca.lib.utils');




traversal.coerce();

let tf = '';
let images = []

writeProvider();

// ciclo for per ogni nodo
for (let id in clout.vertexes) {
	let vertex = clout.vertexes[id];
    if (tosca.isTosca(vertex, 'NodeTemplate')) {
        tf += convert(vertex);
    }
}


setupImages();
puccini.write(tf);

function writeProvider(){   // scrive prime righe necessarie per tf
    tf += 'terraform {\nrequired_providers {\ndocker = {\nsource  = "kreuzwerker/docker"\nversion = "~> 2.13.0"\n}\n}\n}\n\nprovider "docker" {}\n\n';
}

function setupImages(){
    for (let i = 0; i < images.length; i++) {
        tf += 'resource "docker_image" "image'+i+'" {\n';
        tf += 'name = "'+images[i]+'"\n';
        tf += '}\n';
    }

}



function convert(node){  // dato un nodo tosca ritorna la stringa tf equivalente

    for (let name in node.properties.types) {
        switch (name){
        case 'terraform::terraform_network':
            return convertNetwork(node);
            break
        case "terraform::terraform_host":
            return convertHost(node);
            break;
        case "terraform::terraform_volume":
            return converVolume(node);
            break;
        }
    }
    return 'error'

    function converVolume(node){
        let properties = node.properties;
        let s= '';


        s += 'resource "docker_volume" "' + properties['name'] + '"{\n';
        for (let p in properties.properties){
            let property = properties.properties[p];

            s += baseConverter(p,property);
        }

        s += '}\n'
        return s;
    }

    function convertHost(node){
        let properties = node.properties;
        let s= '';


        s += 'resource "docker_container" "' + properties['name'] + '"{\n';
        for (let p in properties.properties){
            let property = properties.properties[p];

            if ( p === 'image'){
                let name = String(property)
                if (images.includes[name]){
                    s += 'image = docker_image.image'+images.indexOf[name]+'.latest\n';
                }else{
                    s += 'image = docker_image.image'+images.length+'.latest\n';
                    images.push(name);
                }
                continue;
            }



            if(p === 'volumes'){ // TODO
                for (let volume in property){
                    s += 'volumes {\n'
                    s += convertGeneric(property[volume]) + '\n';
                    s += '}\n'
                }
                continue;
            }

            if(p === 'command'){
                s += p +' = ';
                s += JSON.stringify(property) +'\n';
                continue;
            }

            if(p === 'env'){
                s += p + '= [\n';
                for (let key in property){
                    s += '"'+key+'='+property[key]+'",\n';
                }
                s = s.slice(0, -2);
                s += '\n]\n';
                continue;
            }


            s += baseConverter(p, property);
        }


        s += '}\n'
        return s;
    }

    function convertNetwork(node){
        let properties = node.properties;
        let s= '';
        s += 'resource "docker_network" "' + properties['name'] + '"{\n';

        for (let p in properties.properties){
            s += baseConverter(p, properties.properties[p]);
        }


        for (let p in properties.attributes){
            let type = typeof property;
            if ( p === 'state'){
                continue;
            }
            let temp = baseConverter(p,properties.attributes[p]);
           if (temp.length > 1){
                s += 'ipam_config {\n';
                s += temp;
                s += '}\n';
           }
        }

        s += '}\n';

        return s;
    }

    function convertGeneric(node){
        let s = ''
        for (let p in node){
            s+= baseConverter(p,node[p]);
        }
        return s;
    }

    function baseConverter(name, value){
        let type = typeof value;
        let s = '';

        if (!value){
        return s;
        }

        switch(type){
                case "object":
                    s += name + ' {\n';
                    s += convertGeneric(value);
                    s += '}\n';
                    break;
                case "string":
                    s += name +' = "'+value+'"';
                    break;
                default:
                    s += name +' = '+value;
                    break;
            }
        s += '\n';
        return s;
    }

}