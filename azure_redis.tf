/*provider "azurerm" {
    subscription_id = var.subscription_id
    client_id = var.client_id
  }

  resource "azurerm_resource_group" "redis" {
    name = "ai-dev"
    location = "eastus"
  }
Not needed, is already defined*/
  resource "azurerm_redis_cache" "word_cache_redis" {
    name = "${local.prefix}-${var.ccx_ai_svc_name}-redis"
    resource_group_name = azurerm_resource_group.redis.name
    location = azurerm_resource_group.redis.location
    family = "C"
    sku_name = "Standard"
    capacity = 1
    enable_non_ssl_port = true
    public_network_access_enabled = false
    redis_version = 6
    #shard_count = 3 Not set for Standard tier

      /* The default policy on this has better policy than the one mentioned here.
    redis_configuration {
      maxmemory_policy = "LRU"
    }
    access_keys {
      primary = "my-primary-key"
      secondary = "my-secondary-key"
    }
     The "access_keys" is not a valid block for resource of type azurerm_redis_cache. See https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache for more details.
     This is an output and not an input */
  }
         
  resource "azurerm_private_endpoint" "redis" {
  name                = "${azurerm_redis_cache.word_cache_redis.name}-endpoint"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${azurerm_redis_cache.word_cache_redis.name}-privateconnection"
    is_manual_connection           = false
    subresource_names              = ["redis"]
    private_connection_resource_id = azurerm_redis_cache.word_cache_redis.id
  }
  
  tags = local.tags
  lifecycle {
    ignore_changes = [
      private_dns_zone_group
    ]
  }
}

  output "redis_hostname" {
    value = azurerm_redis_cache.word_cache_redis.hostname
  }

  output "redis_port" {
    value = azurerm_redis_cache.word_cache_redis.port
  }

  output "redis_primary_key" {
    value = azurerm_redis_cache.word_cache_redis.access_keys.primary
  }

  output "redis_secondary_key" {
    value = azurerm_redis_cache.word_cache_redis.access_keys.secondary
  }
}
    
