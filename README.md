# Ecobee Prometheus Exporter

This is a Prometheus exporter for Ecobee thermostats. The exporter is designed to run as a Docker container, making calls to the Ecobee API to fetch data. The fetched data is then exported on the /metrics endpoint, making it easy to integrate with your Prometheus setup.

## Project Status

This project is currently a work in progress. We are actively developing and adding new features. Contributions are welcome!

### Currently Supported Metrics

The following metrics are currently supported:

* `ecobee_sensor_temperature_fahrenheit`: This metric represents the temperature data from the sensor in Fahrenheit.
* `ecobee_sensor_humidity_ratio`: This metric represents the humidity data from the sensor.
* `ecobee_thermostat_desired_cool_fahrenheit`: This metric represents the desired cool temperature from the thermostat in Fahrenheit.
* `ecobee_thermostat_desired_heat_fahrenheit`: This metric represents the desired heat temperature from the thermostat in Fahrenheit.
* `ecobee_thermostat_desired_humidity_ratio`: This metric represents the desired humidity ratio from the thermostat.

### Future Work

Add support for temperature metrics in Celsius.

## Contributing

This exporter is an Elixir Phoenix application. If you're interested in contributing, please check the [Phoenix Documentation](https://www.hexdocs.com/phoenix) to learn about the framework.

To start your Phoenix server:

Run mix setup to install and setup dependencies

## Deployment
The application is containerized using Docker. To deploy the application, you can use the following steps:

### Build the image
`docker build -t ecobee-exporter .`

### Run the image

You must generate a custom developer app with Ecobee.  The instructions for doing so are beyong the scope of this document. To get started, visit the [Ecobee Developer API site](https://www.ecobee.com/en-us/developers/).

You must create a pin-based app.  Once you've done that, grab the app's api key.

#### Environment

| Name                       | Type                      | Required |
|----------------------------|---------------------------|----------|
| ECOBEE_APPLICATION_API_KEY | String (your app api key) | True     |

#### Persisting session data

The exporter stores it's auth token in the following directory: `/app/bin/priv/data`

In order to persist authentication state, you should bind this to a persistant volume or mount a directory on your host.

Create a persistent volume: `docker volume create ecobee_exporter_data`

Run the Docker container: `docker run -p 4000:4000 -v ecobee_exporter_data:/app/bin/priv/data ecobee-exporter`

Please note that the application will be accessible on port 4000.

## License
This project is open source under the MIT license. See the LICENSE file for more information.

## Contact
If you have any questions or suggestions, please open an issue on GitHub. We appreciate your feedback!