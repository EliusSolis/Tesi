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
        tf += '}\n\n';
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
        case "terraform::terraform_image":
            return convertImage(node);
            break;
        }
    }
    return 'error'

    function converVolume(node){
        let properties = node.properties;
        let s= '';


        s += 'resource "docker_volume" "' + properties['name'] + '"{\n';
        s += convertGeneric(properties.properties)

        s += '}\n\n\n'
        return s;
    }

    function convertImage(node){
        let properties = node.properties;
        let s= '';


        s += 'resource "docker_image" "' + properties['name'] + '"{\n';
        s += convertGeneric(properties.properties)

        s += '}\n\n\n'
        return s;
    }

    function convertHost(node){
        let properties = node.properties;
        let s= '';


        s += 'resource "docker_container" "' + properties['name'] + '"{\n';
        for (let p in properties.properties){
            let property = properties.properties[p];

            switch(p){
                case('image'):
                    let name = String(property)
                    if (images.includes[name]){
                        s += 'image = docker_image.image'+images.indexOf[name]+'.latest\n';
                    }else{
                        s += 'image = docker_image.image'+images.length+'.latest\n';
                        images.push(name);
                    }
                    break;

                case('volumes'):
                    for (let volume in property){
                        s += 'volumes {\n'
                        s += convertGeneric(property[volume]) + '\n';
                        s += '}\n\n'
                    }
                    break;

                case 'command':
                    s += p +' = ';
                    s += JSON.stringify(property) +'\n';
                    break;

                case 'env':
                    s += p + '= [\n';
                    for (let key in property){
                        s += '"'+key+'='+property[key]+'",\n';
                    }
                    s = s.slice(0, -2);
                    s += '\n]\n';
                    break;

                case('networks'):
                    for (let net in property){
                        s += 'networks_advanced {\n'
                        s += convertGeneric(property[net]) + '\n';
                        s += '}\n\n'
                    }
                    break;

                case('capabilities'):
                    s += 'capabilities {\n'
                        if ('add' in property) {
                            s += 'add = ' + JSON.stringify(property['add']) + '\n';
                        }
                        if ('drop' in property) {
                            s += 'drop = ' + JSON.stringify(property['drop']) + '\n';
                        }
                    s += '}\n\n';
                    break;

                default:
                    s += baseConverter(p, property);
            }
        }


        s += '}\n\n\n'
        return s;
    }

    function convertNetwork(node){
        let properties = node.properties;
        let s= '';
        s += 'resource "docker_network" "' + properties['name'] + '"{\n';

        s+= convertGeneric(properties.properties)

        let temp = ''
        for (let p in properties.attributes){
            let type = typeof property;
            if ( p === 'state'){
                continue;
            }
            temp += baseConverter(p,properties.attributes[p]);

        }
        if (temp.replace("\n","").length > 1){
                s += 'ipam_config {\n';
                s += temp;
                s += '}\n\n';
           }

        s += '}\n\n';

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
                    s += '}\n\n';
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
