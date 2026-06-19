#include "type_check.h"

gboolean tokamak_gtk_widget_is_box(GtkWidget *widget)
{
  return GTK_IS_BOX(widget);
}

gboolean tokamak_gtk_widget_is_stack(GtkWidget *widget)
{
  return GTK_IS_STACK(widget);
}

gboolean tokamak_gtk_widget_is_window(GtkWidget *widget)
{
  return GTK_IS_WINDOW(widget);
}
