#!/bin/bash

npx prisma db push --accept-data-loss

node server.js