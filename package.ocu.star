ocuroot("0.3.0")

#########################################
## Pipeline functions
## Functions to implement the pipeline
#########################################

def build():
    shell("docker build . -t quickstart-frontend:latest")
    return done(
        outputs={
            "image": "quickstart-frontend:latest",
        },
    )

def up(environment={}, network_name="", image=""):
    container_name = "quickstart-frontend-{}".format(environment["name"])
    shell("docker stop {name} && docker rm {name}".format(name=container_name), continue_on_error=True)
    shell("""docker run -d \
    --name {name} \
    --network {network} \
    -p {port}:8080 \
    -e TIME_SERVICE_URL=http://quickstart-time-service-{environment_name}:8080 \
    -e WEATHER_SERVICE_URL=http://quickstart-weather-service-{environment_name}:8080 \
    -e MESSAGE_SERVICE_URL=http://quickstart-message-service-{environment_name}:8080 \
    -e ENVIRONMENT={environment_name} \
    {image}""".format(
        name=container_name,
        network=network_name,
        port=environment["attributes"]["frontend_port"],
        image=image,
        environment_name=environment["name"],
    ))
    return done()

def down(environment={}, network_name="", image=""):
    container_name = "quickstart-frontend-{}".format(environment["name"])
    shell("docker stop {name} && docker rm {name}".format(name=container_name))
    return done()

#########################################
## Pipeline definition
## Defining the order of the pipeline
#########################################

task(
    name="build",
    fn=build
)

phase(
    name="staging",
    tasks= [
        deploy(
            up=up,
            down=down,
            environment=e,
            inputs={
                "image": ref("./task/build#output/image"),
                "network_name": ref("./-/network/package.ocu.star/@/deploy/{}#output/network_name".format(e.name)),
            }
        ) for e in environments() if e.attributes["type"] == "staging"
    ]
)

phase(
    name="production",
    tasks= [
        deploy(
            up=up,
            down=down,
            environment=e,
            inputs={
                "image": ref("./task/build#output/image"),
                "network_name": ref("./-/network/package.ocu.star/@/deploy/{}#output/network_name".format(e.name)),
            }
        ) for e in environments() if e.attributes["type"] == "production"
    ]
)