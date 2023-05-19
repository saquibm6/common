provider "azurerm" {
    subscription_id = var.subscription_id
    client_id = var.client_id
  }

  resource "azurerm_resource_group" "redis" {
    name = "ai-dev"
    location = "eastus"
  }

  resource "azurerm_redis_cache" "word_cache_redis" {
    name = "word-cache-memoryDB"
    resource_group_name = azurerm_resource_group.redis.name
    location = azurerm_resource_group.redis.location
    family = "P"
    sku_name = "Premium"
    capacity = 1
    enable_non_ssl_port = true
    public_network_access_enabled = false
    redis_version = 6
    shard_count = 3

    redis_configuration {
      maxmemory_policy = "LRU"
    }
    access_keys {
      primary = "my-primary-key"
      secondary = "my-secondary-key"
    }
  }

  output "redis_hostname" {
    value = azurerm_redis_cache.redis.hostname
  }

  output "redis_port" {
    value = azurerm_redis_cache.redis.port
  }

  output "redis_primary_key" {
    value = azurerm_redis_cache.redis.access_keys.primary
  }

  output "redis_secondary_key" {
    value = azurerm_redis_cache.redis.access_keys.secondary
  }
}
    
