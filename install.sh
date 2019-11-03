#!/usr/bin/env bash
set -e
MIN_RAM=3072 # MB
ENV_FILE='.env'

echo "Checking minimum requirements..."

if [ "$RAM_AVAILABLE_IN_DOCKER" -lt "$MIN_RAM" ]; then
    echo "FAIL: Expected minimum RAM available to Docker to be $MIN_RAM MB but found $RAM_AVAILABLE_IN_DOCKER MB"
    exit -1
fi

echo ""
echo "Creating volumes for persistent storage..."
echo "Created $(docker volume create --name=sentry-data)."
echo "Created $(docker volume create --name=sentry-postgres)."
echo ""

if [ -f "$ENV_FILE" ]; then
  echo "$ENV_FILE already exists, skipped creation."
else
  echo "Creating $ENV_FILE..."
  cp -n .env.example "$ENV_FILE"
fi

echo ""
echo "Building and tagging Docker images..."
echo ""
docker-compose build
echo ""
echo "Docker images built."

echo ""
echo "Generating secret key..."
# This is to escape the secret key to be used in sed below
SECRET_KEY=$(docker-compose run --rm web config generate-secret-key 2> /dev/null | tail -n1 | sed -e 's/[\/&]/\\&/g')
sed -i -e 's/^SENTRY_SECRET_KEY=.*$/SENTRY_SECRET_KEY='"$SECRET_KEY"'/' $ENV_FILE
echo "Secret key written to $ENV_FILE"

echo ""
echo "Setting up database..."
if [ $CI ]; then
  docker-compose run --rm web upgrade --noinput
  echo ""
  echo "Did not prompt for user creation due to non-interactive shell."
  echo "Run the following command to create one yourself (recommended):"
  echo ""
  echo "  docker-compose run --rm web createuser"
  echo ""
else
  docker-compose run --rm web upgrade
fi

# cleanup

echo ""
echo "----------------"
echo "You're all done! Run the following command get Sentry running:"
echo ""
echo "  docker-compose up -d"
echo ""
