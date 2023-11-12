# Ecobee Prometheus Exporter

This is a Prometheus exporter for Ecobee thermostats. The exporter is designed to run as a Docker container, making calls to the Ecobee API to fetch data. The fetched data is then exported on the /metrics endpoint, making it easy to integrate with your Prometheus setup.

## Project Status

This project is currently a work in progress. We are actively developing and adding new features. Contributions are welcome!

### Currently Supported Metrics

#### Current sensor data metrics

* `ecobee_sensor_temperature_fahrenheit`: actual temperature from the thermostat in Fahrenheit
* `ecobee_sensor_humidity_ratio`: humidity data from the sensor

##### Labels

* `name`: the sensor name
* `thermostat_name`: the thermostat name the sensor is paired to
* `thermostat_id`: the thermostat id the sensor is paired to

#### Desired thermostat metrics

* `ecobee_thermostat_desired_humidity_ratio`: desired humidity ratio the thermostat, type label has two options: cool or heat
* `ecobee_thermostat_desired_temperature_fahrenheit`: desired termperature from the thermostat in Fahrenheit

##### Labels

* `type`: (only available for desired temperatur metric) heat or cool
* `thermostat_name`: the thermostat name the sensor is paired to
* `thermostat_id`: the thermostat id the sensor is paired to

### Future Work

* Add support for temperature metrics in Celsius.
* Add support for runtime statistics

## Deployment

### Create an Ecobee Developer Account and App

1. Developer Account:
   * Visit the Ecobee Developer Portal and sign up.
   * Provide email, password, and name. Verify your email.

2. Register Application:
   * Log in to Developer Portal.
   * Click "Register" to fill out application form.
   * Submit to receive API key. Find this under "API Keys" tab.

3. Create Pin-Based App:
   * In the Developer Panel, select 'Create New', choose 'ecobee PIN' for authorization, and save your API Key.

4. Obtain Pin and Authorization Code:
   * Submit API key to receive ecobeePin and code.
   * Log in to Ecobee portal, go to 'My Apps', add your application by authorizing ecobeePin.

5. Access and Refresh Tokens:
   * Populate API Key and Authorization Code to get Access Token.
   * Copy Refresh Token from Step 2's response to get a new set of tokens.

### Prepare to run

#### Persisting session data

The exporter stores it's auth token in the following directory: `/app/bin/priv/data`

In order to persist authentication state, you should bind this to a persistant volume or mount a directory on your host.

Create a persistent volume: `docker volume create ecobee_exporter_data`

Run the Docker container: `docker run -p 4000:4000 -v ecobee_exporter_data:/app/bin/priv/data ecobee-exporter`

Please note that the application will be accessible on port 4000.

#### Environment

| Name                       | Type                      | Required |
|----------------------------|---------------------------|----------|
| ECOBEE_APPLICATION_API_KEY | String (your app api key) | True     |

#### Running your container

```bash
# Create a docker volume to persist your session data
docker volume create ecobee_exporter_data

docker run \
  -p 4000:4000 \
  -v ecobee_exporter_data:/app/bin/priv/data \
  -e ECOBEE_APPLICATION_API_KEY=$ECOBEE_APPLICATION_API_KEY
  tylerdavis/ecobee-exporter
```

#### Authenticating the exporter

With the container running successfully, you can now visit `http://$CONTAINER_IP:4000/`. From here, follow the instructions on screen to complete the authentication.  You will see a success message when authentication is completed successfully. Finally, confirm your data is being exported by visiting `http://$CONTAINER_IP:4000/metrics`.

## Contributing

This exporter is an Elixir Phoenix application. If you're interested in contributing, please check the [Phoenix Documentation](https://www.hexdocs.com/phoenix) to learn about the framework.

### Build the image
`docker build -t ecobee-exporter .`

## License
This project is open source under the MIT license. See the LICENSE file for more information.

## Contact
If you have any questions or suggestions, please open an issue on GitHub. We appreciate your feedback!