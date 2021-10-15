#!/usr/bin/env python
# -*- coding: utf-8 -*-
  
def lambda_handler(event, context):
    print("Hello from app1!")
    print(event)

    return event
