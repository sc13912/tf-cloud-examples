output "folders" {
  description = "Created folder IDs"
  value       = zipmap([google_folder.common.display_name, google_folder.prod.display_name, google_folder.dev.display_name], [google_folder.common.id, google_folder.prod.id, google_folder.dev.id])
}

output "host_projects" {
  description = "Created host projects"
  value       = zipmap([module.common_host.project_name, module.prod_host.project_name], [module.common_host.project_id, module.prod_host.project_id])
}

output "service_projects" {
  description = "Created service projects"
  value       = zipmap([module.common_service_1.project_name, module.prod_service_1.project_name], [module.common_service_1.project_id, module.prod_service_1.project_id])
}

