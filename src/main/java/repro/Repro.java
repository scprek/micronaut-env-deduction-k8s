package repro;

import io.micronaut.context.ApplicationContext;

public class Repro {
    public static void main(String[] args) {
        try (ApplicationContext ctx = ApplicationContext.run()) {
            System.out.println("active environments: " + ctx.getEnvironment().getActiveNames());
        }
    }
}
