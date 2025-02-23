package frege.compiler;


import frege.MD;

import java.nio.file.Files;


/*
 * $Revision$
 * $Id$
 * $Author$
 */

public class JavaUtils {

    public static MD.FregePackage getFrege(ClassLoader loader, String pack) throws ClassNotFoundException {
		Class<?> cl = null;
	    cl = loader.loadClass(pack);
		return cl.getAnnotation(MD.FregePackage.class);
	}

	/** get the lambda annotations */
	public static MD.LambdaClasses getLambdas(ClassLoader loader, String pack) throws  ClassNotFoundException {
	    Class<?> cl = null;
	    cl = loader.loadClass(pack);
	    return cl.getAnnotation(MD.LambdaClasses.class);
	}

    // left for backward compatibility
	public static MD.Operator[] getOperators(ClassLoader loader, String pack) throws ClassNotFoundException {
		Class<?> cl = null;
	    cl = loader.loadClass(pack);
	    // System.err.println("curr. class loader " + MD.FregePackage.class.getClassLoader());
	    // System.err.println("using class loader " + loader);
	    // System.err.println("with parent loader " + loader.getParent());
		MD.FregePackage os = cl.getAnnotation(MD.FregePackage.class);
		if (os == null) return null;
		return os.ops();
	}


	public static int runJavac(final String[] cmd) {
		try {
			// String cmd = "javac -cp " + cp + " -d " + d + " " + src;
			int cex = 0;
			StringBuilder sb = new StringBuilder();
			for (String s : cmd) { sb.append(s); sb.append(" "); }
			System.out.println("running: " + sb.toString());
			Process jp = Runtime.getRuntime().exec(cmd);
			// if (Common.verbose)
				
			java.io.InputStream is = jp.getErrorStream();
			while ((cex = is.read()) >= 0) {
				System.err.write(cex);
			}
			if ((cex = jp.waitFor()) != 0) {
				System.err.println("javac terminated with exit code " + cex);
			}
			return cex;
		} catch (java.io.IOException e) {
			System.err.println("Can't javac  (" + e.getMessage() + ")");
		} catch (InterruptedException e) {
			System.err.println("Can't javac  (" + e.getMessage() + ")");
		}
		return 1;
	}

	/**
	 *  Reads the named (text) file in the given encoding.
	 *
	 *  @return a String representing the contents of the file
	 */
	 static public String slurp(String filename, String encoding) throws Exception {
	     return new String(
	         Files.readAllBytes(
	             java.nio.file.FileSystems.getDefault().getPath(filename)),
	         encoding);
	 }


}
